## MetaData
Question Type : Single Choice
Module : M6 - OpenShift and Kubernetes

## Question
10. During a rolling update, a Deployment's new pods keep failing, but Kubernetes has already terminated most of the old, working pods. What setting would have limited this damage?

## Options
Option 1 : A tighter CPU limit on the container, since resource limits control how aggressively old pods are terminated

Option 2 : A larger replica count, since more replicas always mean safer rollouts regardless of other settings

Option 3 : maxUnavailable and maxSurge in the rollout strategy, which control how many old pods can be taken down before new ones are confirmed healthy

Option 4 : A shorter image pull timeout, since slow pulls are the most common cause of rollout damage

## Answers
Option 3 : 1

## Correct Answer Feedback
Correct. maxUnavailable and maxSurge directly control rollout pacing — setting maxUnavailable low (or to 0) ensures old pods aren't torn down until enough new pods are confirmed healthy via readiness probes, preventing a bad rollout from taking down the whole service at once.

## Number of Retries
1