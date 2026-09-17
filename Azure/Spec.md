This Package Includes

Deliverables Included in the Package

- Lab Guide (Getting Started + 7 module pages — one page per module)
- Master Document
- Inline Validations (4 modules: M1, M2, M4, M5 — all real checks against a live environment)
- Inline Questions (35 total: 5 per module, across all 7 modules)
- ARM Deployment + Custom Script Extension (bootstrap fully implemented)
- Facilitator Solution Guide

Assessment Profile

- Assessment: Messaging & Eventing — Messaging Operations & Automation (name and level as per the assignment sheet)
- Tribe: Integration Tribe — Competency: Messaging & Eventing — Level: Intermediate
- Modules: 7, each worth 10 marks (70 total) — pass threshold 70% per module
- Delivery: single Lab VM (`Standard_D4s_v3`). Kafka+Zookeeper and IBM MQ run as
  Docker containers; Ansible and Python (with kafka-python) are installed natively
  for the M4/M5 automation tasks. M3, M6, M7 have no infrastructure deployed.

Module scoring

- M1 IBM MQ — validation (10 marks), plus 5 reinforcement questions (ungraded)
- M2 Apache Kafka and KSQL — validation (10 marks), plus 5 reinforcement questions (ungraded)
- M3 Elastic and Logstash — 5 questions, 2 marks each (10 marks)
- M4 Ansible — validation (10 marks), plus 5 reinforcement questions (ungraded)
- M5 Python — validation (10 marks), plus 5 reinforcement questions (ungraded)
- M6 OpenShift and Kubernetes — 5 questions, 2 marks each (10 marks)
- M7 Git and CI/CD (Azure DevOps) — 5 questions, 2 marks each (10 marks)

VM capacity rationale

- M1 (IBM MQ) and M2 (Kafka+Zookeeper) are the only two stateful services on this VM
  — both are lightweight single containers with fast, deterministic startup, well
  within a `D4s_v3`'s capacity together.
- M4 (Ansible) and M5 (Python) add no infrastructure of their own — they validate
  automation written against the M1/M2 containers, so they're effectively free to
  include once M1/M2 are running.
- M3 (Elastic/Logstash), M6 (Kubernetes), and M7 (real Azure DevOps) were evaluated
  and intentionally excluded from hands-on scope on this VM — see prior design
  discussion: Elasticsearch/Logstash adds real JVM memory pressure and pipeline
  ordering dependencies, a Kubernetes control plane doesn't coexist reliably with the
  other services within a 105-minute provisioning/assessment window, and a real Azure
  DevOps integration requires external tenant credentials outside this template's
  control. All three remain viable as a future phase on separate resources.

Exclusions / Flags for package owner review

- IBM MQ container uses the public `icr.io/ibm-messaging/mq:latest` developer image
  — free for development use but licensed (not open source); confirm this is
  acceptable before publishing
- M4's validator independently re-checks both containers' real state and compares
  against the attendee's report, rather than trusting the report at face value
- End-to-end build has not yet been tested on a provisioned Azure VM — recommend one
  full dry run before publishing
- Question content pending SME review before production use
