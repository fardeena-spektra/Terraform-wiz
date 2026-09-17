## MetaData
Question Type : Single Choice
Module : M4 - Ansible

## Question
2. A playbook run reports "changed: 0" every time, even immediately after you've manually changed the target configuration. What should you check?

## Options
Option 1 : Whether the playbook needs to be renamed, since Ansible ties change detection to the playbook's filename

Option 2 : Whether the inventory file has too many hosts, which can suppress change reporting above a threshold

Option 3 : Whether Ansible needs to be reinstalled, since a corrupted install can silently disable change tracking

Option 4 : Whether the task is actually idempotent and correctly detecting the current state, rather than always reporting no change regardless of reality

## Answers
Option 4 : 1

## Correct Answer Feedback
Correct. "changed: 0" should reflect that the task checked real state and found nothing to do — if that's not true, the task's state-detection logic is the place to investigate, not the playbook name or inventory size.

## Number of Retries
1