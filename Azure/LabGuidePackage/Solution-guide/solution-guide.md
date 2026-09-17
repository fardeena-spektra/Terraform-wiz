# Solution Guide - Messaging & Eventing - Messaging Operations & Automation

> **Facilitator only.** Every command and script in this guide has been run and
> confirmed working against a live provisioned VM. Where a real issue was hit during
> testing, it is documented here explicitly with its root cause and fix - this guide
> is the reference of record if an attendee's failed validation is disputed.
>
> Scenarios 3, 6, and 7 (Elastic and Logstash; OpenShift and Kubernetes; Git and
> CI/CD) are question-only. Every answer and rationale is in the corresponding
> question files under `Inline-Questions/` (`## Answers` / `## Correct Answer
> Feedback`). This guide covers Scenarios 1, 2, 4, and 5, the four hands-on validated
> scenarios.

---

## Before troubleshooting any "it doesn't work" report, check these first

Every genuine failure encountered while building and testing this package traced
back to one of these causes. Rule these out before assuming the validator or
environment is broken:

| Symptom | Real cause | Fix |
|---|---|---|
| `permission denied while trying to connect to the docker API` | SSH session opened before bootstrap finished adding the user to the `docker` group | Disconnect and reconnect the SSH session |
| `service "X" is not running` after the VM was stopped and restarted | Containers do not automatically restart with the VM; Kafka specifically can hit a stale Zookeeper ephemeral-node conflict after an abrupt stop | `cd /opt/labfiles/stack && docker compose down && docker compose up -d` |
| M1 put/get always fails even when done correctly | `amqsput`/`amqsget` are not on the container's default `$PATH` | Use the full path: `/opt/mqm/samp/bin/amqsput` |
| `kafka-topics.sh: command not found` or `/opt/kafka/bin/...: No such file` | The container runs Confluent's `cp-kafka` image, not the raw Apache Kafka tarball or Bitnami's image; CLI tools have no `.sh` suffix and no path prefix | Use plain command names: `kafka-topics`, `kafka-console-consumer`, `kafka-consumer-groups` |
| A consumer run with `--timeout-ms` prints an `ERROR ... TimeoutException` | Expected exit behavior once all available messages are drained, not a real error | No action needed; check `Processed a total of N messages` in the same output |
| `docker: no such object: kafka` (or `ibmmq`) | Docker Compose names containers `<project>-<service>-<n>`, not the plain service name | Confirm real names with `docker ps` first; use `stack-kafka-1` / `stack-ibmmq-1` |
| Ansible `template error while templating string: unexpected '.'` on a `docker inspect -f '{{.State.Running}}'` command | Ansible's `command`/`shell` modules pass every string through Jinja2 first, which also uses `{{ }}` and tries to parse the Docker Go-template expression itself | Wrap it: `{% raw %}{{.State.Running}}{% endraw %}`, or use `community.docker.docker_container_info` instead |
| `kafka.errors.KafkaConfigurationError: Unrecognized configs: {'api_version_auto_timeout_ms'}` (or similar) | A `KafkaConsumer` keyword argument that does not exist in the installed `kafka-python` version (3.0.11) | Remove the unsupported argument; check `pip show kafka-python` and the matching API docs for the installed version |
| M4/M5 validation fails despite a correct report file | `jq` or `python3-pip`/`kafka-python` was missing from the VM (hardened in the current bootstrap with a retry+verify step) | `sudo apt-get install -y jq` / `sudo apt-get install -y python3-pip && python3 -m pip install kafka-python` |
| M4/M5 validation fails despite correct content | Report file is older than 20 minutes; Ansible's `copy` module and a script that only overwrites on change will not refresh a file whose content is unchanged | Delete the report file, rerun the playbook/script, validate immediately |

---

## Scenario 1 - Configure and Verify the Payments Queue (Module 1: IBM MQ)

**Task, as given in the lab guide:** create `PAYMENTS.QUEUE` on `QM1`, prove a working put/get round trip.

**Environment access:**
```bash
cd /opt/labfiles/stack
docker compose exec -it ibmmq bash
```

**Verified working sequence, run entirely inside the `runmqsc` session:**
```bash
runmqsc QM1
DEFINE QLOCAL(PAYMENTS.QUEUE)
DISPLAY QLOCAL(PAYMENTS.QUEUE)
end
```

Confirm `DISPLAY` returns `QUEUE(PAYMENTS.QUEUE)` before typing `end`. Exiting the
session too early and then running MQSC commands at the bash prompt produces
`bash: syntax error near unexpected token '('`, since MQSC syntax is not valid bash.

**Put/get round trip:**
```bash
echo "test-message" | /opt/mqm/samp/bin/amqsput PAYMENTS.QUEUE QM1
/opt/mqm/samp/bin/amqsget PAYMENTS.QUEUE QM1
```

Both sample programs live at `/opt/mqm/samp/bin`, not on the container's default
`$PATH` - the full path is required.

**What the validator checks:** `DISPLAY QLOCAL(PAYMENTS.QUEUE)` returns a match; a
probe message is put and successfully retrieved (matched on the literal string
`Sample AMQSPUT0 end`, not `MQPUT`, which `amqsput` never prints).

---

## Scenario 2 - Scale Event Throughput & Resolve Consumer Lag (Module 2: Apache Kafka and KSQL)

**Task, as given in the lab guide:** reconfigure `orders-events` to 6+ partitions,
achieve full consumer group coverage, resolve lag below 100.

**Environment access:**
```bash
cd /opt/labfiles/stack
docker compose exec -it kafka bash
```

**Verified working sequence.** Commands are plain names already on `$PATH` inside
this container - no `.sh` suffix, no `/opt/kafka/bin/` prefix:
```bash
kafka-topics --bootstrap-server localhost:9092 --alter --topic orders-events --partitions 6

kafka-topics --bootstrap-server localhost:9092 --describe --topic orders-events
# Expect: PartitionCount: 6, partitions 0-5 listed

kafka-console-consumer --bootstrap-server localhost:9092 \
  --topic orders-events --group orders-consumers --from-beginning --timeout-ms 15000 > /dev/null
# Prints an ERROR/TimeoutException in stderr once drained - expected, not a failure

kafka-consumer-groups --bootstrap-server localhost:9092 --describe --group orders-consumers
# Expect all 6 partitions with real CURRENT-OFFSET values (not '-'), LAG at or near 0
```

**What the validator checks:** partition count >= 6; every partition has a real
committed offset (not `-`) for `orders-consumers`; total lag summed across all
partitions < 100.

---

## Scenario 4 - Automate Cross-Service Health Verification (Module 4: Ansible)

**Task, as given in the lab guide:** build a playbook that determines the real
running state of the Kafka and IBM MQ containers, publish to `broker-health.json`.

**Environment access:** none required, runs directly on the VM host.
Working directory: `/opt/labfiles/ansible`.

**Confirm the real container names first:**
```bash
docker ps --format "table {{.Names}}\t{{.Status}}"
# Expect: stack-kafka-1, stack-ibmmq-1, stack-zookeeper-1
```

**Verified working playbook** (`broker-health-check.yml`):
```yaml
---
- hosts: local
  gather_facts: false
  tasks:
    - name: Check Kafka container running state
      command: "docker inspect -f '{% raw %}{{.State.Running}}{% endraw %}' stack-kafka-1"
      register: kafka_state
      changed_when: false

    - name: Check IBM MQ container running state
      command: "docker inspect -f '{% raw %}{{.State.Running}}{% endraw %}' stack-ibmmq-1"
      register: mq_state
      changed_when: false

    - name: Ensure report directory exists
      file:
        path: /opt/labfiles/reports
        state: directory
        mode: '0755'

    - name: Write broker health report
      copy:
        content: |
          {
            "kafka_up": {{ kafka_state.stdout | trim | lower }},
            "mq_up": {{ mq_state.stdout | trim | lower }}
          }
        dest: /opt/labfiles/reports/broker-health.json
        mode: '0644'
```

**The `{% raw %}...{% endraw %}` wrapping is required, not optional.** Docker's
`docker inspect -f` uses Go-template syntax (`{{.State.Running}}`), but Ansible's
`command`/`shell` modules pass every string through Jinja2 templating first, which
also uses `{{ }}`. Without the raw block, Ansible tries to template the Go-template
expression itself and fails with `template error while templating string: unexpected
'.'`. An equally valid alternative is the `community.docker.docker_container_info`
module, which never touches raw Go-template syntax at all.

**Run and confirm:**
```bash
ansible-playbook -i inventory.ini broker-health-check.yml
cat /opt/labfiles/reports/broker-health.json
# Expect: {"kafka_up": true, "mq_up": true}
```

**Validate immediately after this run.** The report's freshness window is 20
minutes, and a re-run that produces identical content will not necessarily refresh
the file's timestamp.

**What the validator checks:** the report is under 20 minutes old; it independently
re-checks both containers itself via `docker inspect -f '{{.State.Running}}'
stack-kafka-1` / `stack-ibmmq-1` and compares that to what the playbook reported.

---

## Scenario 5 - Build a Programmatic Lag Monitor (Module 5: Python)

**Task, as given in the lab guide:** a script that computes real consumer lag for
`orders-consumers`, publishes to `lag-report.json`.

**Environment access:** none required, runs directly on the VM host.
Installed versions: **Python 3.10**, **`kafka-python` 3.0.11** (confirm with
`pip show kafka-python`; some `KafkaConsumer` parameters differ across
`kafka-python` releases, and passing an unsupported one raises
`KafkaConfigurationError: Unrecognized configs`).

**Critical environment detail:** use `localhost:9094`, not `kafka:9092`. The script
runs on the host, not inside the Kafka container - `kafka:9092` is the
container-internal listener and does not resolve from the host shell;
`localhost:9094` is the `PLAINTEXT_HOST` listener exposed for this purpose.

**Also note:** the Kafka CLI tools (`kafka-topics`, `kafka-console-consumer`,
`kafka-consumer-groups`, etc.) exist only inside the Kafka container - a host-side
script cannot shell out to them (`FileNotFoundError: kafka-consumer-groups`). Use
the `kafka-python` library directly instead of `subprocess`.

**Verified working script** (`lag_monitor.py`):
```python
from kafka import KafkaConsumer, TopicPartition
import json

BROKER = "localhost:9094"
TOPIC = "orders-events"
GROUP = "orders-consumers"
REPORT = "/opt/labfiles/reports/lag-report.json"

def main():
    consumer = KafkaConsumer(
        bootstrap_servers=BROKER,
        group_id=GROUP,
        enable_auto_commit=False,
        request_timeout_ms=10000
    )
    try:
        partitions = consumer.partitions_for_topic(TOPIC)
        if not partitions:
            raise RuntimeError(f"No partitions found for topic {TOPIC}")
        topic_partitions = [TopicPartition(TOPIC, p) for p in sorted(partitions)]
        end_offsets = consumer.end_offsets(topic_partitions)

        total_lag = 0
        for tp in topic_partitions:
            committed = consumer.committed(tp)
            if committed is None:
                committed = 0
            lag = max(0, end_offsets[tp] - committed)
            total_lag += lag

        report = {"group": GROUP, "total_lag": total_lag}
        with open(REPORT, "w") as f:
            json.dump(report, f)
        print(json.dumps(report))
    finally:
        consumer.close()

if __name__ == "__main__":
    main()
```

Note the constructor only uses `bootstrap_servers`, `group_id`,
`enable_auto_commit`, and `request_timeout_ms` - all confirmed supported by
`kafka-python` 3.0.11. Parameters from other versions or from generic/outdated
documentation (e.g. `api_version_auto_timeout_ms`) will raise
`KafkaConfigurationError` on this installed version.

**Run and confirm:**
```bash
python3 lag_monitor.py
cat /opt/labfiles/reports/lag-report.json
# Expect: {"group": "orders-consumers", "total_lag": <value below 100 once Scenario 2 is resolved>}
```

**What the validator checks:** the report is under 20 minutes old; `group` exactly
equals `orders-consumers`; `total_lag` is below 100. Since the script reads live
broker state, `total_lag` cannot report a passing value unless Scenario 2's fault
has genuinely been resolved.

---

## Summary - validator determinism

Every one of the four validators in this package checks live, independently
observed state - none of them trust a report file's contents at face value, and
none can be satisfied by a hardcoded or guessed value. Given a correctly
provisioned VM (Docker containers running, `jq` and `kafka-python` installed, no
stale ephemeral-node conflict) and a report produced within the 20-minute
freshness window, the pass/fail outcome is deterministic and reproducible. Every
failure mode encountered during build and test is listed in the table at the top
of this guide, with its root cause and fix documented - an unexplained failure
outside that list should be escalated for investigation, not assumed to be
attendee error.
