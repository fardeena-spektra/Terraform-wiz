## MetaData
Question Type : Single Choice
Module : M3 - Elastic and Logstash

## Question
3. Documents arriving in Elasticsearch via Logstash are tagged with _grokparsefailure. What does this indicate?

## Options
Option 1 : Logstash has stopped running, and the tag reflects the last state before the process exited

Option 2 : The documents were sent to the wrong index, and the tag flags a routing misconfiguration

Option 3 : The grok filter pattern in the pipeline does not match the actual format of the incoming log lines

Option 4 : Elasticsearch has rejected the documents due to a disk quota being exceeded on the cluster

## Answers
Option 3 : 2

## Number of Retries
1
