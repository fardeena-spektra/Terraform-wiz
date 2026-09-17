## MetaData
Question Type : Single Choice
Module : M7 - Git and CI/CD (Azure DevOps)

## Question
1. You've edited a pipeline YAML file locally and committed the change, but the pipeline still runs against the old configuration. What is the most likely reason?

## Options
Option 1 : Azure DevOps does not support YAML pipelines, so it silently falls back to the last known classic pipeline

Option 2 : The commit was never pushed to the remote branch the pipeline is triggered from

Option 3 : The pipeline needs to be deleted and recreated, since pipelines cache their configuration permanently after first use

Option 4 : Git commits are automatically synced without a push, so this is unlikely to be the actual cause

## Answers
Option 2 : 2

## Number of Retries
1
