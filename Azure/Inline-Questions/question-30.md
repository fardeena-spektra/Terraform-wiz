## MetaData
Question Type : Single Choice
Module : M6 - OpenShift and Kubernetes

## Question
5. You want to change a broker's heap size setting cluster-wide without rebuilding the container image. What is the standard Kubernetes-native way to do this?

## Options
Option 1 : Edit the value directly inside the running container's filesystem, which is often the quickest option to reach for

Option 2 : Store the setting in a ConfigMap (or Secret, if sensitive) and mount it into the pod

Option 3 : Change it in the Kubernetes API server's own configuration, since that's where cluster-wide settings typically live

Option 4 : Hardcode the value into the Docker image and push a new tag every time it changes

## Answers
Option 2 : 2

## Number of Retries
1
