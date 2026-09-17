## MetaData
Question Type : Single Choice
Module : M1 - IBM MQ

## Question
2. A queue's current depth is climbing steadily and is approaching MAXDEPTH. What is the most likely cause?

## Options
Option 1 : The queue manager needs to be restarted, since a restart typically resets an incorrectly climbing depth counter

Option 2 : The queue was defined with the wrong name, causing messages to accumulate under the wrong identifier

Option 3 : The consuming application has stopped or slowed down while producers keep putting messages

Option 4 : MQ automatically deletes old messages, so no action is needed as depth will self-correct over time

## Answers
Option 3 : 2

## Correct Answer Feedback
Correct. Rising queue depth is a supply/demand imbalance — messages are arriving faster than they're being consumed, which points to a stalled, crashed, or under-capacity consumer rather than a queue manager or naming problem.

## Number of Retries
1