## MetaData
Question Type : Single Choice
Module : M7 - Git and CI/CD (Azure DevOps)

## Question
5. Pushing to a feature branch does not trigger the pipeline, even though pushing to main does. What is the most likely cause?

## Options
Option 1 : The pipeline's trigger/branch filter is scoped to specific branches and does not include this feature branch pattern

Option 2 : Feature branches cannot be pushed to Azure DevOps, so no pipeline could ever trigger from one

Option 3 : The pipeline needs to be rebuilt from scratch, since triggers only apply to the branch active at creation time

Option 4 : Git does not support triggering pipelines on non-main branches, regardless of how the pipeline is configured

## Answers
Option 1 : 2

## Number of Retries
1
