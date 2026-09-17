# Instructor Brief - Messaging & Eventing — Messaging Operations & Automation — Intermediate Skills Assessment

**Tribe:** Integration Tribe · **Competency:** Messaging & Eventing · **Level:** Intermediate
**Delivery:** Single Lab VM (`Standard_D4s_v3`) — Kafka+Zookeeper and IBM MQ as containers for M1/M2/M4/M5; M3/M6/M7 are question-only
**Pass threshold:** 70% per module · **Marks:** 7 modules × 10 = 70

## What the candidate does (from the assignment sheet)

Configure a Kafka topic and consumer group for a given throughput target; automate a broker health check; diagnose a seeded message-loss or lag fault. This scope spans Modules 1, 2, 4, and 5 in this build.

## Module map

- M1 IBM MQ — validation: create PAYMENTS.QUEUE on QM1, prove a put/get round trip (10 marks) + 5 reinforcement questions
- M2 Apache Kafka and KSQL — validation: orders-events to 6+ partitions, full consumer coverage, lag resolved (10 marks) + 5 reinforcement questions
- M3 Elastic and Logstash — 5 questions × 2 marks (10 marks)
- M4 Ansible — validation: playbook produces an accurate broker-health.json for both Kafka and MQ, cross-checked against real container state (10 marks) + 5 reinforcement questions
- M5 Python — validation: script produces an accurate lag-report.json against live broker state (10 marks) + 5 reinforcement questions
- M6 OpenShift and Kubernetes — 5 questions × 2 marks (10 marks)
- M7 Git and CI/CD (Azure DevOps) — 5 questions × 2 marks (10 marks)

## Status

BUILD COMPLETE — bootstrap and all 4 validators (M1, M2, M4, M5) are implemented
against a real single-VM environment. All 35 inline questions (5 per module across
all 7 modules) are in place and wired into their exercise pages. Before publishing:
(1) run one full end-to-end deployment on a provisioned Azure VM to confirm bootstrap
timing and validator accuracy; (2) SME review of all 35 inline questions; (3) confirm
IBM MQ image licensing is acceptable; (4) confirm the M3/M6/M7 question-only scope is
acceptable for this VM-capacity phase, per the rationale in Spec.md.
