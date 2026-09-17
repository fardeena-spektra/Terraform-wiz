## MetaData
Question Type : True/False
Module : M7 - Git and CI/CD (Azure DevOps)

## Question
9. True or False: A variable group in Azure DevOps is automatically scoped to only the pipeline that originally created it, and cannot be linked to or reused by any other pipeline.

## Options
Option 1 : True

Option 2 : False

## Answers
Option 2 : 1

## Correct Answer Feedback
Correct — False. Variable groups are designed to be shared — once created, they can be linked into any number of pipelines that need the same set of variables (e.g. shared connection strings or thresholds), rather than being locked to a single pipeline.

## Number of Retries
1