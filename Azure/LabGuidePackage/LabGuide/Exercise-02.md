# **Scenario 2: Scale Event Throughput & Resolve Consumer Lag**

### Module 2 - Apache Kafka and KSQL

## **Overview**

The `orders-events` stream is under-provisioned for its target throughput, and its consumer group has fallen behind on processing. Both issues exist on the live stream right now and need to be resolved in place, not rebuilt from scratch.

This is an **assessment**: the task gives you the **required outcome** and the **exact conditions** the validator checks, not the steps. Work the Kafka tooling yourself, then press **Validate** to score it.

> **Note:** Kafka runs as a container on this VM. Log into it and work from inside: `cd /opt/labfiles/stack && docker compose exec -it kafka bash`. Bootstrap server from inside the container: `localhost:9092`. Topic: `orders-events`. Consumer group: `orders-consumers`. Kafka CLI commands in this container are plain names already on `$PATH`, with no `.sh` suffix and no path prefix (`kafka-topics`, not `kafka-topics.sh` or `/opt/kafka/bin/kafka-topics.sh`). A consumer run with a timeout will print a `TimeoutException` in its output once it has drained all available messages, this is expected exit behavior, not a failure. Type `exit` when done to return to the VM shell.

## **Task 1: Meet the throughput target and clear the backlog**

**Goal:** Reconfigure `orders-events` to sustain its target throughput, and bring `orders-consumers` fully current across the whole topic.

**Required outcome:**

- `orders-events` has **6 or more partitions**.
- Consumer group `orders-consumers` has a **committed offset on every partition** of the topic, proving it has actually consumed across the full partition set, not just the original two.
- `orders-consumers` **total lag across all partitions is below 100**.

The validator checks the topic's live partition count, confirms every partition shows a real committed offset (not a placeholder) for `orders-consumers`, and sums lag across all partitions. All three conditions must hold together.

> **Congratulations** on completing the task! Now, it's time to validate it. Here are the steps:
> - Hit the Validate button for the corresponding task. If you receive a success message, you can proceed to the next task.
> - If not, carefully read the error message and retry the step, following the instructions in the guide.
> - If you need any assistance, please contact us at labs-support@spektrasystems.com. We are available 24/7 to help you out.

<validation step="64bc6880-85a1-4628-b191-bf14345b277e" />

Click **Next** to begin Scenario 3.

