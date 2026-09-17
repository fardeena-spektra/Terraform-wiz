## MetaData
Question Type : Single Choice
Module : M4 - Ansible

## Question
3. A playbook task fails against a remote host with "Permission denied". What should you check first?

## Options
Option 1 : Whether the playbook has too many tasks, since Ansible can throttle execution on long task lists

Option 2 : Whether the target host needs to be rebooted, since a stale session can trigger permission errors

Option 3 : Whether privilege escalation (become/sudo) is configured correctly and the connecting user has the needed rights

Option 4 : Whether the YAML file has too many blank lines, which can interfere with Ansible's parser

## Answers
Option 3 : 1

## Correct Answer Feedback
Correct. "Permission denied" almost always points to an authentication or privilege escalation problem — checking SSH access and become/sudo configuration is the direct path to the cause.

## Number of Retries
1