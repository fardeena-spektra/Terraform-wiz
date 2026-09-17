## MetaData
Question Type : True/False
Module : M3 - Elastic and Logstash

## Question
10. True or False: A single Logstash pipeline can only be configured with one output destination, so sending data to both Elasticsearch and a local file at the same time would require two separate pipelines.

## Options
Option 1 : True

Option 2 : False

## Answers
Option 2 : 1

## Correct Answer Feedback
Correct — False. A Logstash pipeline's output block can contain multiple output plugins — for example an elasticsearch output and a file output defined side by side — and Logstash sends each event to all of them, no separate pipeline required.

## Number of Retries
1