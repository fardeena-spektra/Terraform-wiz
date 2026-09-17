## MetaData
Question Type : Single Choice
Module : M2 - Apache Kafka and KSQL

## Question
1. The orders-events topic needs higher parallel consumption throughput, but its replication factor is fixed at 1 (single broker). Which change increases consumer parallelism without touching replication?

## Options
Option 1 : Delete and recreate the consumer group, since a fresh group will automatically consume with higher parallelism

Option 2 : Restart the Kafka broker, since a restart resets internal throughput limits on existing topics

Option 3 : Increase the replication factor, since more replicas allow more consumers to read from the topic

Option 4 : Increase the number of partitions on the topic, since partition count is the unit of parallelism a consumer group can spread across

## Answers
Option 4 : 1

## Correct Answer Feedback
Correct. Partition count is the unit of parallelism a consumer group can spread across — more partitions allow more consumers in the group to read concurrently. Replication factor governs durability, not throughput.

## Number of Retries
1