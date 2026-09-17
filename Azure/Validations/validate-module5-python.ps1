Import-Module Az.Compute
Import-Module Az.Accounts

# Validation step: b1b6d4c8-97a7-4ddc-af01-9e4c4c9208e9
# Module 5 - Python

# Variables provided by CloudLabs
$deployment_id     = $deployment_id
$resourceGroupName = $resourceGroupName
$sub_id            = $sub_id
$vmName            = "labvm-$deployment_id"

# Set subscription
Select-AzSubscription -SubscriptionId $sub_id

# Retry logic
$stopRetry = $false
[int]$retryCount = 0
$maxRetries = 3

do {
    try {

        # Script to run inside VM. It must echo the sentinel "Validation Success"
        # ONLY when every check passes; otherwise echo "Validation Failed".
        $script = @'
#!/bin/bash
set -uo pipefail
export PATH=$PATH:/usr/bin:/usr/local/bin

# Checks: lag-report.json exists, is fresh, names the correct consumer group,
# and reports total_lag under threshold — proving the attendee's script
# correctly measured live lag rather than writing a hardcoded value.
report=/opt/labfiles/reports/lag-report.json
fresh_ok=false; group_ok=false; lag_ok=false

if [ -f "$report" ]; then
  age_min=$(( ( $(date +%s) - $(stat -c %Y "$report") ) / 60 ))
  [ "$age_min" -le 20 ] && fresh_ok=true

  group=$(jq -r '.group // ""' "$report" 2>/dev/null)
  lag=$(jq -r '.total_lag // 99999' "$report" 2>/dev/null)

  [ "$group" = "orders-consumers" ] && group_ok=true
  [ "$lag" -lt 100 ] && lag_ok=true
fi

if [ "$fresh_ok" = true ] && [ "$group_ok" = true ] && [ "$lag_ok" = true ]; then
  echo "Validation Success"
else
  echo "Validation Failed"
fi
exit 0
'@

        # Execute inside VM
        $result = Invoke-AzVMRunCommand `
            -ResourceGroupName $resourceGroupName `
            -VMName $vmName `
            -CommandId "RunShellScript" `
            -ScriptString $script

        $vmOutput = ($result.Value[0].Message | Out-String).Trim()

        if ($vmOutput -match "Validation Success") {

            $message = @{
                Status  = "Succeeded"
                Message = "lag-report.json is present, recent, and shows orders-consumers lag resolved below threshold on VM '$vmName'."
            } | ConvertTo-Json
        }
        else {

            $message = @{
                Status  = "Failed"
                Message = "lag-report.json is missing, stale, or still shows high lag for orders-consumers on VM '$vmName'. Complete the script, resolve the lag, and run it again."
            } | ConvertTo-Json
        }

        # Return JSON response
        Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = [System.Net.HttpStatusCode]::OK
            Body       = $message
        })

        $stopRetry = $true
    }
    catch {

        if ($retryCount -ge $maxRetries) {

            $message = @{
                Status  = "Failed"
                Message = "Retry for validation process has been exhausted. Please try after sometime."
            } | ConvertTo-Json

            Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
                StatusCode = [System.Net.HttpStatusCode]::OK
                Body       = $message
            })

            $stopRetry = $true
        }
        else {
            Write-Host "Validation failed. Retrying... ($($retryCount + 1)/$maxRetries)"
            Start-Sleep -Seconds 10
            $retryCount++
        }
    }

} while ($stopRetry -eq $false)
