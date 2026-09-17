## MetaData
Question Type : Single Choice
Module : M2 - Apache Kafka and KSQL

## Question
5. A topic has a retention period of 7 days. What happens to a message that a consumer group never read within that window?

## Options
Option 1 : The message stays indefinitely on the broker until it is manually deleted by an administrator

Option 2 : The message is moved automatically to a dead-letter topic for later inspection and reprocessing

Option 3 : Kafka automatically extends the retention window until every registered consumer group has read the message

Option 4 : The message is deleted once its retention period expires, regardless of whether it was ever consumed

## Answers
Option 4 : 1

## Correct Answer Feedback
Correct. Retention is time-based (or size-based), not consumption-based — Kafka deletes messages once they age out of the retention window regardless of whether any consumer group has read them, which is why a slow or stalled consumer can genuinely lose access to unread data.

## Number of Retries
1