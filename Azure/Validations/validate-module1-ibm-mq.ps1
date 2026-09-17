Import-Module Az.Compute
Import-Module Az.Accounts

# Validation step: 48e59922-5f60-4c95-9347-0f67cef53d34
# Module 1 - IBM MQ

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

# Checks: PAYMENTS.QUEUE exists on QM1, and a put/get round trip against it succeeds.
cd /opt/labfiles/stack || { echo "Validation Failed"; exit 0; }

queue_ok=false; put_ok=false; get_ok=false

# Queue exists
queue_exists=$(docker compose exec -T ibmmq bash -c "echo 'DISPLAY QLOCAL(PAYMENTS.QUEUE)' | runmqsc QM1" 2>/dev/null | grep -c "QUEUE(PAYMENTS.QUEUE)")
[ "$queue_exists" -ge 1 ] && queue_ok=true

# Put a probe message
if [ "$queue_ok" = true ]; then
  put_result=$(docker compose exec -T ibmmq bash -c "echo 'validator-probe-message' | /opt/mqm/samp/bin/amqsput PAYMENTS.QUEUE QM1" 2>/dev/null | grep -c "Sample AMQSPUT0 end")
  [ "$put_result" -ge 1 ] && put_ok=true
fi

# Get it back
if [ "$put_ok" = true ]; then
  get_result=$(docker compose exec -T ibmmq bash -c "/opt/mqm/samp/bin/amqsget PAYMENTS.QUEUE QM1" 2>/dev/null | grep -c "validator-probe-message")
  [ "$get_result" -ge 1 ] && get_ok=true
fi

if [ "$queue_ok" = true ] && [ "$put_ok" = true ] && [ "$get_ok" = true ]; then
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
                Message = "PAYMENTS.QUEUE exists on queue manager QM1, and a put/get round trip succeeded on VM '$vmName'."
            } | ConvertTo-Json
        }
        else {

            $message = @{
                Status  = "Failed"
                Message = "PAYMENTS.QUEUE was not found on QM1, or a put/get round trip failed on VM '$vmName'. Create the queue and verify a message can be put and retrieved, then validate again."
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
