## MetaData
Question Type : Single Choice
Module : M5 - Python

## Question
5. A lag-calculation script occasionally reports a negative lag value, which shouldn't be possible. What is the most likely explanation?

## Options
Option 1 : The script is using stale offset metadata — a partition reassignment or rebalance happened between fetching the two offset values being compared

Option 2 : Python's subtraction operator is unreliable, so this is often the first thing worth ruling out when values look wrong

Option 3 : The broker deliberately reports negative numbers as a warning signal, which is a common thing to suspect at first glance

Option 4 : Negative lag means the script has a syntax error, since a working script should never be able to print an invalid number

## Answers
Option 1 : 1

## Correct Answer Feedback
Correct. Negative lag usually means the two offset values being compared were fetched at different points in time relative to a partition reassignment — the fix is to refresh metadata and fetch both offsets consistently before computing the difference.

## Number of Retries
1