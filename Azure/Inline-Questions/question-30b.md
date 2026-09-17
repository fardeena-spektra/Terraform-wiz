## MetaData
Question Type : True/False
Module : M6 - OpenShift and Kubernetes

## Question
7. True or False: In OpenShift, the oc command-line tool is required, and the standard Kubernetes kubectl tool cannot be used to manage an OpenShift cluster.

## Options
Option 1 : True

Option 2 : False

## Answers
Option 2 : 1

## Correct Answer Feedback
Correct — False. OpenShift is built on the standard Kubernetes API, so kubectl works against an OpenShift cluster for anything Kubernetes-native (pods, deployments, services). oc adds convenience commands and access to OpenShift-specific resources (Routes, Projects, BuildConfigs, ImageStreams) that kubectl doesn't know about, but it isn't a hard requirement for basic cluster management.

## Number of Retries
1