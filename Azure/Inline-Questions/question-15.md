## MetaData
Question Type : Single Choice
Module : M3 - Elastic and Logstash

## Question
5. An operational index is growing unbounded and disk usage keeps climbing. What is the most likely missing control?

## Options
Option 1 : A stricter grok pattern, since looser parsing rules cause more raw fields to be stored per document

Option 2 : More Kibana dashboards, since additional dashboards help distribute the query load across the cluster

Option 3 : An index lifecycle management (ILM) or retention policy to roll over and delete old indices

Option 4 : A larger Logstash heap size, since low heap causes documents to be duplicated during buffering

## Answers
Option 3 : 2

## Number of Retries
1
