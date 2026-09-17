## MetaData
Question Type : Single Choice
Module : M6 - OpenShift and Kubernetes

## Question
3. A stateful broker pod loses its data every time it restarts. What is missing from its deployment configuration?

## Options
Option 1 : A LoadBalancer service, since this is a common first guess when a pod isn't behaving as expected

Option 2 : A larger container image, since limited image size is often assumed to affect data retention

Option 3 : More CPU limits, which is frequently the first resource setting people check when a pod misbehaves

Option 4 : A PersistentVolumeClaim backing the pod's data directory (or it was deployed as stateless rather than a StatefulSet)

## Answers
Option 4 : 2

## Number of Retries
1
