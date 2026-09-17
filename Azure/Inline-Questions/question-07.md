## MetaData
Question Type : Single Choice
Module : M2 - Apache Kafka and KSQL

## Question
2. A consumer group's lag suddenly spikes for a short period, then recovers on its own without any manual intervention. What is the most likely explanation?

## Options
Option 1 : The broker's replication factor changed automatically, briefly pausing message delivery to consumers

Option 2 : Kafka silently duplicated all messages, temporarily inflating the lag count until deduplication completed

Option 3 : A consumer group rebalance temporarily paused consumption while partitions were being reassigned

Option 4 : The topic's data was corrupted on disk, causing a brief delay while Kafka repaired the affected segments

## Answers
Option 3 : 1

## Correct Answer Feedback
Correct. Rebalances are a normal, expected part of consumer group operation — when a consumer joins, leaves, or is considered dead, partitions are reassigned and consumption briefly pauses. A short lag spike that self-recovers is the classic signature of this, not corruption or data loss.

## Number of Retries
1