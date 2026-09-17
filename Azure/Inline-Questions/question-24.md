## MetaData
Question Type : Single Choice
Module : M5 - Python

## Question
4. A long-running monitoring script's memory usage keeps growing over time. What should you check first?

## Options
Option 1 : Whether the script needs to print less output, since reducing console output is a common first troubleshooting step

Option 2 : Whether the operating system needs more disk space, since disk pressure is often the first thing worth ruling out

Option 3 : Whether the script's variable names are too long, since this is an easy thing to check before digging deeper

Option 4 : Whether connections, consumers, or clients are being properly closed instead of accumulating unclosed resources

## Answers
Option 4 : 1

## Correct Answer Feedback
Correct. Steady memory growth in a long-running script is a classic resource-leak symptom — unclosed connections or clients accumulating over time is the most common cause, and print statements or variable naming have no bearing on memory usage.

## Number of Retries
1