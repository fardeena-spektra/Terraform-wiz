## MetaData
Question Type : True/False
Module : M7 - Git and CI/CD (Azure DevOps)

## Question
8. True or False: A service connection in Azure DevOps must be explicitly authorized before a pipeline can use it to deploy to or interact with an external resource (such as an Azure subscription or a container registry).

## Options
Option 1 : True

Option 2 : False

## Answers
Option 1 : 1

## Correct Answer Feedback
Correct — True. Service connections represent credentials/permissions to an external system, and Azure DevOps requires them to be authorized for use — either by an administrator granting access, or via an approval prompt the first time a pipeline attempts to use one, preventing pipelines from silently gaining access to resources they weren't granted.

## Number of Retries
1