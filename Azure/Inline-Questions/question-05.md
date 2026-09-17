## MetaData
Question Type : Single Choice
Module : M1 - IBM MQ

## Question
5. An application receives reason code 2035 (MQRC_NOT_AUTHORIZED) when trying to open a queue. What is the correct first action?

## Options
Option 1 : Restart the queue manager, since most authorization errors are automatically cleared by a fresh restart

Option 2 : Delete and recreate the queue, since a newly defined queue will not carry over old permission errors

Option 3 : Check the authority records for the queue and confirm the application's user ID has the required permissions

Option 4 : Increase the queue's MAXDEPTH value, since reason code 2035 can occur when a queue is nearing its maximum depth

## Answers
Option 3 : 1

## Correct Answer Feedback
Correct. 2035 is specifically an authorization failure — it points directly at permissions (via setmqaut or equivalent), not at queue capacity, queue manager health, or queue definition issues.

## Number of Retries
1