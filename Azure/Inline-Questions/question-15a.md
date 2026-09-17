## MetaData
Question Type : True/False
Module : M3 - Elastic and Logstash

## Question
6. True or False: Updating a document in Elasticsearch modifies the existing document in place, the same way an UPDATE statement works in a traditional relational database.

## Options
Option 1 : True

Option 2 : False

## Answers
Option 2 : 1

## Correct Answer Feedback
Correct — False. Elasticsearch documents are immutable once written to a Lucene segment. An "update" actually marks the old version as deleted and indexes a brand new document version — Elasticsearch handles this internally so it looks like an in-place update from the API, but the underlying mechanism is create-and-replace, not true in-place modification.

## Number of Retries
1