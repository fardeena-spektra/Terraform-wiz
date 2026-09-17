## MetaData
Question Type : True/False
Module : M3 - Elastic and Logstash

## Question
7. True or False: Filters in a Logstash pipeline execute in the exact order they are written in the configuration file, from top to bottom.

## Options
Option 1 : True

Option 2 : False

## Answers
Option 1 : 1

## Correct Answer Feedback
Correct — True. Logstash processes filter blocks sequentially in the order they appear in the pipeline config — this matters in practice, since a later filter can depend on a field a mutate or grok filter earlier in the file has already created.

## Number of Retries
1