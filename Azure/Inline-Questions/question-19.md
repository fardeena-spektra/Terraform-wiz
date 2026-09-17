## MetaData
Question Type : Single Choice
Module : M4 - Ansible

## Question
4. A playbook runs successfully but appears to target the wrong set of hosts. What should you verify?

## Options
Option 1 : Whether the inventory groups and the play's "hosts" value correctly match the intended target hosts

Option 2 : Whether the playbook has a syntax error, since Ansible silently redirects execution to a default host group when one is found

Option 3 : Whether Ansible needs a newer Python version, since outdated versions are known to misread inventory group definitions

Option 4 : Whether the tasks are written in the correct order, since task ordering can override which hosts a play actually targets

## Answers
Option 1 : 1

## Correct Answer Feedback
Correct. Running against the wrong hosts is almost always an inventory/host-matching issue — verify group membership and the "hosts" line in the play before suspecting syntax or task ordering.

## Number of Retries
1