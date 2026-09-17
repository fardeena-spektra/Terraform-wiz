## MetaData
Question Type : Single Choice

Module : M1 - IBM MQ

## Question
1. A put/get test against a queue succeeds, but messages placed by an upstream application are not being retrieved by the downstream consumer application. What should you check first?

## Options
Option 1 : Whether the downstream application is connecting to the correct queue manager and queue name

Option 2 : Whether the queue manager's disk is full, since a full disk can silently block new messages from being consumed

Option 3 : Whether IBM MQ needs to be reinstalled, since a corrupted install can cause consumers to stop receiving messages

Option 4 : Whether the queue should be deleted and recreated, since a stale queue definition can block consumer delivery

## Answers
Option 1 : 2

## Correct Answer Feedback
Correct. A working manual put/get proves the queue itself is healthy — the most common cause of a silent consumer gap is a connection or naming mismatch on the downstream side, not queue or disk corruption.

## Number of Retries
1