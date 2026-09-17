## MetaData
Question Type : True/False
Module : M6 - OpenShift and Kubernetes

## Question
9. True or False: OpenShift's Security Context Constraints (SCCs) restrict containers from running as root by default — a stricter default posture than a stock Kubernetes cluster with no Pod Security Admission policy configured.

## Options
Option 1 : True

Option 2 : False

## Answers
Option 1 : 1

## Correct Answer Feedback
Correct — True. This is one of the meaningful differences between OpenShift and vanilla Kubernetes: OpenShift ships with restrictive SCCs applied out of the box, commonly blocking containers that expect to run as root (a frequent surprise when porting a container image that assumed unrestricted Kubernetes defaults).

## Number of Retries
1