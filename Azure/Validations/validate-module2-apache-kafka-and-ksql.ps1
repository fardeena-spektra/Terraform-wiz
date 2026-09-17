Import-Module Az.Compute
Import-Module Az.Accounts

# Validation step: 53af5b47-96f2-43e2-a062-0e9159925771
# Module 2 - Apache Kafka and KSQL

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

# Checks: orders-events has 6+ partitions, orders-consumers has committed offsets
# on every partition, and total lag across the topic is below threshold.
cd /opt/labfiles/stack || { echo "Validation Failed"; exit 0; }

throughput_ok=false; coverage_ok=false; lag_ok=false

partitions=$(docker compose exec -T kafka kafka-topics --bootstrap-server localhost:9092 \
  --describe --topic orders-events 2>/dev/null | head -1 | grep -oE "PartitionCount: [0-9]+" | grep -oE "[0-9]+")
partitions=${partitions:-0}
[ "$partitions" -ge 6 ] && throughput_ok=true

partitions_with_offsets=$(docker compose exec -T kafka kafka-consumer-groups --bootstrap-server localhost:9092 \
  --describe --group orders-consumers 2>/dev/null | awk 'NR>1 && $3 != "-" {count++} END {print count+0}')
[ "$partitions_with_offsets" -ge "$partitions" ] && [ "$partitions" -ge 1 ] && coverage_ok=true

lag=$(docker compose exec -T kafka kafka-consumer-groups --bootstrap-server localhost:9092 \
  --describe --group orders-consumers 2>/dev/null | awk 'NR>1 {sum+=$6} END {print sum+0}')
[ "${lag:-99999}" -lt 100 ] && lag_ok=true

if [ "$throughput_ok" = true ] && [ "$coverage_ok" = true ] && [ "$lag_ok" = true ]; then
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
                Message = "orders-events has 6 or more partitions, orders-consumers has committed offsets across every partition, and total lag is resolved on VM '$vmName'."
            } | ConvertTo-Json
        }
        else {

            $message = @{
                Status  = "Failed"
                Message = "Throughput target, consumer group coverage, or the lag fault is not yet resolved on VM '$vmName'. Reconfigure orders-events to 6+ partitions, ensure orders-consumers covers every partition, and resolve the lag, then validate again."
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
