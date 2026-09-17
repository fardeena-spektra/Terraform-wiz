Import-Module Az.Compute
Import-Module Az.Accounts

# Validation step: 7c2e9a14-3d5b-4f88-9e6a-2b7f1c4d8a90
# Module 4 - Ansible

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

# Checks: broker-health.json exists, is fresh (<20 min), and its kafka_up / mq_up
# flags match the real, independently-observed state of both containers — this
# confirms the attendee's automation is checking something real, not hardcoded.
report=/opt/labfiles/reports/broker-health.json
fresh_ok=false; kafka_ok=false; mq_ok=false

if [ -f "$report" ]; then
  age_min=$(( ( $(date +%s) - $(stat -c %Y "$report") ) / 60 ))
  [ "$age_min" -le 20 ] && fresh_ok=true

  kafka_up=$(jq -r '.kafka_up // false' "$report" 2>/dev/null)
  mq_up=$(jq -r '.mq_up // false' "$report" 2>/dev/null)

  actual_kafka=$(docker inspect -f '{{.State.Running}}' stack-kafka-1 2>/dev/null || echo false)
  actual_mq=$(docker inspect -f '{{.State.Running}}' stack-ibmmq-1 2>/dev/null || echo false)

  [ "$kafka_up" = "$actual_kafka" ] && kafka_ok=true
  [ "$mq_up" = "$actual_mq" ] && mq_ok=true
fi

if [ "$fresh_ok" = true ] && [ "$kafka_ok" = true ] && [ "$mq_ok" = true ]; then
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
                Message = "broker-health.json is present, recent, and accurately reflects the real state of both the Kafka and IBM MQ containers on VM '$vmName'."
            } | ConvertTo-Json
        }
        else {

            $message = @{
                Status  = "Failed"
                Message = "broker-health.json is missing, stale, or does not accurately reflect the running containers on VM '$vmName'. Complete the playbook so it checks real container state, run it again, then validate."
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
