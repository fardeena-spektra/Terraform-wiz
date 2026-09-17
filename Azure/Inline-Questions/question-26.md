## MetaData
Question Type : Single Choice
Module : M6 - OpenShift and Kubernetes

## Question
1. A broker pod is deployed on OpenShift/Kubernetes and keeps restarting (CrashLoopBackOff). What is the correct first diagnostic step?

## Options
Option 1 : Delete the deployment and redeploy immediately, since a fresh deployment is often the fastest way to clear a crash loop

Option 2 : Restart the entire cluster, which is a common first response when a single pod is behaving unexpectedly

Option 3 : Check the pod's logs and recent events (kubectl/oc logs, kubectl/oc describe pod)

Option 4 : Scale the deployment to zero replicas, since this is a quick way to stop the restarts while investigating

## Answers
Option 3 : 2

## Number of Retries
1
