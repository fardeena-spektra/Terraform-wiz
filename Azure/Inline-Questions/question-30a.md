## MetaData
Question Type : True/False
Module : M6 - OpenShift and Kubernetes

## Question
6. True or False: A pod's IP address is guaranteed to stay the same across restarts, so it is safe to hardcode a pod's IP in another application's configuration.

## Options
Option 1 : True

Option 2 : False

## Answers
Option 2 : 1

## Correct Answer Feedback
Correct — False. Pod IPs are ephemeral and can change whenever a pod restarts or is rescheduled. Applications should connect via a Service, which provides a stable name/IP that routes to whichever pods are currently healthy.

## Number of Retries
1