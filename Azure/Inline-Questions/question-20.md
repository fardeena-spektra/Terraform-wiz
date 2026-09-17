## MetaData
Question Type : Single Choice
Module : M4 - Ansible

## Question
5. A variable set in defaults/main.yml doesn't seem to take effect during a playbook run. What is the most likely explanation?

## Options
Option 1 : Ansible ignores all variables defined in roles, so defaults/main.yml has no effect on the play at all

Option 2 : Defaults only apply on the first playbook run, since Ansible caches variable values after that

Option 3 : Variable precedence — a higher-precedence source (such as group_vars, host_vars, or an extra-vars flag) is overriding the default

Option 4 : The variable name is too long for Ansible's parser to correctly read it from the defaults file

## Answers
Option 3 : 1

## Correct Answer Feedback
Correct. Defaults sit at the lowest precedence level in Ansible's variable resolution order — if a value isn't taking effect, check for the same variable defined elsewhere with higher precedence before assuming the default itself is broken.

## Number of Retries
1