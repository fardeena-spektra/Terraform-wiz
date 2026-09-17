## MetaData
Question Type : Single Choice
Module : M5 - Python

## Question
2. A monitoring script occasionally throws a connection error when reaching the broker, then works fine on the next run. What is the correct way to handle this?

## Options
Option 1 : Add retry logic with backoff around the connection, rather than letting a single transient failure crash the script

Option 2 : Remove all error handling so the script fails fast every time, since surfacing every error immediately is always the safest choice

Option 3 : Restart the entire broker whenever this happens, since a broker restart clears any transient connection issues for good

Option 4 : Ignore the error silently and continue as if nothing happened, since the script will naturally recover on its own

## Answers
Option 1 : 1

## Correct Answer Feedback
Correct. Intermittent connection errors are common in distributed systems — retry-with-backoff handles transient issues gracefully without masking a genuinely persistent failure the way silently ignoring errors would.

## Number of Retries
1