## MetaData
Question Type : Single Choice
Module : M6 - OpenShift and Kubernetes

## Question
8. A pod is stuck in ImagePullBackOff status. What is the most likely cause?

## Options
Option 1 : The cluster has run out of available CPU, so the scheduler is delaying the pull indefinitely

Option 2 : The pod's readiness probe is failing repeatedly, which blocks the image pull step

Option 3 : The image name/tag is incorrect, or the cluster lacks credentials to pull from a private registry

Option 4 : The node's disk is full, which is frequently mistaken for a registry connectivity problem

## Answers
Option 3 : 1

## Correct Answer Feedback
Correct. ImagePullBackOff specifically means Kubernetes could not retrieve the container image — almost always a wrong image reference, a missing tag, or missing/incorrect registry credentials (an imagePullSecret), not a scheduling or probe issue.

## Number of Retries
1