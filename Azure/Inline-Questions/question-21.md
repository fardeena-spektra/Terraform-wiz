## MetaData
Question Type : Single Choice
Module : M5 - Python

## Question
1. A lag-monitoring script reports 0 lag immediately after a consumer group is created, before any messages have been read. What does this most likely indicate?

## Options
Option 1 : The broker is down, since a script can only report a lag value while actively connected to a live broker

Option 2 : Python cannot connect to a message broker, so the script defaults to printing zero for every value

Option 3 : The topic or queue has been deleted, causing all offset comparisons to resolve to zero automatically

Option 4 : The script may be comparing the wrong offsets, or coincidentally the committed offset already equals the log-end offset

## Answers
Option 4 : 1

## Correct Answer Feedback
Correct. A suspiciously clean zero-lag result right after group creation is a sign to double check the offset comparison logic rather than assume everything is fine.

## Number of Retries
1