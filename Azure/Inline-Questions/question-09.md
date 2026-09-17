## MetaData
Question Type : Single Choice
Module : M2 - Apache Kafka and KSQL

## Question
4. In a single-broker Kafka cluster, why can't a topic's replication factor be set to 3?

## Options
Option 1 : Replication factor cannot exceed the number of brokers in the cluster

Option 2 : Replication factor is always fixed at 1 regardless of cluster size

Option 3 : Replication factor only applies to Zookeeper, not Kafka topics

Option 4 : Replication factor can only be set when using ksqlDB

## Answers
Option 1 : 1

## Correct Answer Feedback
Correct. Each replica needs to live on a distinct broker — with only one broker available, a replication factor above 1 has nowhere valid to place the extra copies, so the cluster rejects it.

## Number of Retries
1
