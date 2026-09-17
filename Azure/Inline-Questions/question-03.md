## MetaData
Question Type : Single Choice
Module : M1 - IBM MQ

## Question
3. Messages are appearing on the dead-letter queue instead of their intended destination. What does this generally indicate?

## Options
Option 1 : The dead-letter queue is the default destination for all new messages

Option 2 : MQ could not deliver the message to its target queue, for reasons such as the target being full, undefined, or the message being malformed

Option 3 : The queue manager has crashed

Option 4 : Dead-letter queues only receive messages during scheduled maintenance

## Answers
Option 2 : 2

## Correct Answer Feedback
Correct. The dead-letter queue is MQ's safety net for undeliverable messages — checking the reason code on each dead-lettered message usually points straight to the underlying delivery failure.

## Number of Retries
1
