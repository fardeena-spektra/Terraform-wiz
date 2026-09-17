## MetaData
Question Type : True/False
Module : M3 - Elastic and Logstash

## Question
9. True or False: When a cluster's health status turns "red," indices and shards that are unaffected by the underlying problem continue to serve reads and writes normally, while only the specific data tied to the missing shard becomes unavailable.

## Options
Option 1 : True

Option 2 : False

## Answers
Option 1 : 1

## Correct Answer Feedback
Correct — True. Red status means at least one primary shard is unassigned somewhere in the cluster, and requests that specifically need that missing data will fail — but indices and shards that are unaffected keep functioning normally. Red is serious and should be investigated immediately, but it does not mean the whole cluster stops working.

## Number of Retries
1