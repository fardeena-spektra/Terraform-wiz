## MetaData
Question Type : Single Choice
Module : M6 - OpenShift and Kubernetes

## Question
2. You need broker pods to always land on nodes with sufficient local disk, and never share a node with each other for resilience. Which two Kubernetes concepts together achieve this?

## Options
Option 1 : Node affinity/selectors (for disk-capable nodes) and pod anti-affinity (to spread replicas across nodes)

Option 2 : ConfigMaps and Secrets, which are commonly the first things people reach for when tuning pod placement

Option 3 : A single ReplicaSet with no scheduling rules, since Kubernetes distributes replicas evenly across nodes by default

Option 4 : Horizontal Pod Autoscaler alone, which is often assumed to also handle node placement and resilience

## Answers
Option 1 : 2

## Number of Retries
1
