[Cloudlabs Validator](https://spektra-systems.visualstudio.com/CloudLabs-Validator)

Lab Code: TBD

> Validations run in-VM via the CloudLabs VM Agent against a single Lab VM (Kafka +
> Zookeeper, and IBM MQ, run as Docker containers; Ansible, Python, kafka-python
> installed natively for M4/M5). M3, M6, and M7 are question-only in this build — no
> Elastic/Logstash, Kubernetes, or Git/CI-CD infrastructure is deployed.
> Scoring: M1, M2, M4, M5 = 10 marks each via validation. M3, M6, M7 = 10 marks each
> via 5 inline questions (2 marks each). Pass threshold 70% per module.

| Module | Validation step UUID | Script | Checks |
|---|---|---|---|
| Module 1 — IBM MQ | 48e59922-5f60-4c95-9347-0f67cef53d34 | validate-module1-ibm-mq.sh | PAYMENTS.QUEUE exists on QM1; put/get round trip succeeds |
| Module 2 — Apache Kafka and KSQL | 53af5b47-96f2-43e2-a062-0e9159925771 | validate-module2-apache-kafka-and-ksql.sh | orders-events has 6+ partitions with full consumer group coverage; lag < 100 |
| Module 4 — Ansible | 7c2e9a14-3d5b-4f88-9e6a-2b7f1c4d8a90 | validate-module4-ansible.sh | broker-health.json fresh (<20 min); kafka_up/mq_up match real, independently-checked container state |
| Module 5 — Python | b1b6d4c8-97a7-4ddc-af01-9e4c4c9208e9 | validate-module5-python.sh | lag-report.json fresh (<20 min); group=orders-consumers; total_lag < 100 |

## Design notes

- **M4's validator does not trust the attendee's report at face value** — it
  independently checks each container's real running state via `docker inspect`, then
  compares that to what the playbook reported. A hardcoded or fake result fails the
  moment it disagrees with reality.
- **M5's validator reads live broker state**, not a fixed value — it can only pass once
  the M2 fault has genuinely been resolved, since both modules measure the same live
  consumer group.
- **M1 and M2 validate the services directly**; M4 and M5 validate automation *about*
  those services — deliberately different skills, same infrastructure.

## Assumptions flagged for package owner review

- **M3, M6, M7:** question-only by design — see Spec.md for the VM-capacity rationale
  (Elasticsearch/Logstash, a Kubernetes cluster, and a real Azure DevOps integration
  each add either too much resource overhead or an external dependency to fit
  comfortably alongside M1/M2 on one VM).
- **IBM MQ image:** uses the public `icr.io/ibm-messaging/mq:latest` developer image,
  under IBM's free-for-development-use license (not open source) — confirm this is
  acceptable before publishing.
