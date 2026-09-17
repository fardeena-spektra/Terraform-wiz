## MetaData
Question Type : Single Choice
Module : M4 - Ansible

## Question
1. A health-check playbook reports all services healthy, but one service is actually stopped. What is the most likely cause?

## Options
Option 1 : Ansible does not support checking service state, so playbooks default to reporting everything as healthy

Option 2 : The playbook's check task is not actually querying live state — it's returning a hardcoded or cached result

Option 3 : The inventory file is missing a password, causing the health check task to silently skip

Option 4 : YAML files cannot contain conditionals, so the playbook always falls through to the healthy branch

## Answers
Option 2 : 1

## Correct Answer Feedback
Correct. A health check that always reports healthy regardless of real state means the underlying task isn't performing a live check — the fix is to replace the placeholder logic with a real state query.

## Number of Retries
1