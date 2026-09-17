## MetaData
Question Type : True/False
Module : M3 - Elastic and Logstash

## Question
8. True or False: Elasticsearch can automatically infer a field's data type from the first document that contains it, without requiring an explicit mapping to be defined in advance.

## Options
Option 1 : True

Option 2 : False

## Answers
Option 1 : 1

## Correct Answer Feedback
Correct — True. This is Elasticsearch's dynamic mapping behavior — if a field's type isn't explicitly defined, Elasticsearch infers it from the first document that contains that field and indexes it automatically. An explicit mapping can still be defined upfront for more control, but it is not required before indexing can begin.

## Number of Retries
1