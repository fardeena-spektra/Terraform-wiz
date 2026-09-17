# **Scenario 1: Configure and Verify the Payments Queue**
# **Module 1 - IBM MQ**

```bash
cd /opt/labfiles/stack

docker compose exec ibmmq bash -c '
set -e

echo "===== Checking queue manager ====="
dspmq

echo
echo "===== Starting QM1 if required ====="
strmqm QM1 2>/dev/null || true

echo
echo "===== Creating PAYMENTS.QUEUE ====="
runmqsc QM1 <<EOF
DEFINE QLOCAL(PAYMENTS.QUEUE) REPLACE
ALTER QLOCAL(PAYMENTS.QUEUE) DEFPSIST(YES)
END
EOF

echo
echo "===== Verifying queue ====="
echo "DISPLAY QLOCAL(PAYMENTS.QUEUE)" | runmqsc QM1

echo
echo "===== Testing PUT/GET round trip ====="
echo "PAYMENTS-QUEUE-PROBE" | /opt/mqm/samp/bin/amqsput PAYMENTS.QUEUE QM1

echo
echo "Now retrieving the probe message..."
printf "\n" | /opt/mqm/samp/bin/amqsget PAYMENTS.QUEUE QM1

echo
echo "===== Final queue check ====="
echo "DISPLAY QLOCAL(PAYMENTS.QUEUE) CURDEPTH" | runmqsc QM1

echo
echo "===== Scenario 1 remediation complete ====="
'
```

# **Scenario 2: Scale Event Throughput & Resolve Consumer Lag**
## **Module 2 - Apache Kafka and KSQL**

```bash
cd /opt/labfiles/stack

docker compose exec kafka bash -c '
set -e

echo "===== CURRENT TOPIC ====="
kafka-topics --bootstrap-server localhost:9092 \
  --describe --topic orders-events

echo
echo "===== EXPANDING TO 6 PARTITIONS ====="
kafka-topics --bootstrap-server localhost:9092 \
  --alter \
  --topic orders-events \
  --partitions 6

echo
echo "===== VERIFYING PARTITIONS ====="
kafka-topics --bootstrap-server localhost:9092 \
  --describe --topic orders-events

echo
echo "===== CHECKING CURRENT CONSUMER LAG ====="
kafka-consumer-groups \
  --bootstrap-server localhost:9092 \
  --group orders-consumers \
  --describe || true

echo
echo "===== CONSUMING BACKLOG ====="
echo "The TimeoutException after messages are drained is expected."

timeout 60 kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic orders-events \
  --group orders-consumers \
  --timeout-ms 5000 || true

echo
echo "===== FINAL CONSUMER GROUP STATUS ====="
kafka-consumer-groups \
  --bootstrap-server localhost:9092 \
  --group orders-consumers \
  --describe

echo
echo "===== FINAL TOPIC STATUS ====="
kafka-topics --bootstrap-server localhost:9092 \
  --describe --topic orders-events

echo
echo "===== SCENARIO 2 REMEDIATION COMPLETE ====="
'
```

# **Scenario 4: Automate Cross-Service Health Verification**
## **Module 4 - Ansible**

```bash
cat > broker-health-check.yml <<'EOF'
---
- name: Cross-service health verification
  hosts: local
  become: true
  gather_facts: false

  tasks:
    - name: Get Kafka container state
      ansible.builtin.command:
        cmd: docker inspect --format="{% raw %}{{.State.Running}}{% endraw %}" stack-kafka-1
      register: kafka_state
      changed_when: false

    - name: Get IBM MQ container state
      ansible.builtin.command:
        cmd: docker inspect --format="{% raw %}{{.State.Running}}{% endraw %}" stack-ibmmq-1
      register: mq_state
      changed_when: false

    - name: Create report directory
      ansible.builtin.file:
        path: /opt/labfiles/reports
        state: directory
        mode: "0755"

    - name: Write health report
      ansible.builtin.copy:
        dest: /opt/labfiles/reports/broker-health.json
        mode: "0644"
        content: |
          {
            "kafka_up": {{ kafka_state.stdout | trim | lower }},
            "mq_up": {{ mq_state.stdout | trim | lower }}
          }
EOF

echo "===== PLAYBOOK ====="
cat broker-health-check.yml

echo
echo "===== RUNNING HEALTH CHECK ====="
ansible-playbook -i inventory.ini broker-health-check.yml

echo
echo "===== GENERATED REPORT ====="
cat /opt/labfiles/reports/broker-health.json

echo
echo "===== VERIFY ACTUAL STATES ====="
docker inspect --format='{{.Name}} -> {{.State.Running}}' stack-kafka-1
docker inspect --format='{{.Name}} -> {{.State.Running}}' stack-ibmmq-1
```

# **Scenario 5: Build a Programmatic Lag Monitor**
## **Module 5 - Python**

```bash
cd /opt/labfiles

cat > lag_monitor.py <<'PY'
#!/usr/bin/env python3

import json
import os
from kafka import KafkaConsumer, TopicPartition

BOOTSTRAP = "localhost:9094"
TOPIC = "orders-events"
GROUP = "orders-consumers"
REPORT = "/opt/labfiles/reports/lag-report.json"

consumer = KafkaConsumer(
    bootstrap_servers=BOOTSTRAP,
    group_id=GROUP,
    enable_auto_commit=False,
    consumer_timeout_ms=5000
)

try:
    partitions = consumer.partitions_for_topic(TOPIC)

    if not partitions:
        raise RuntimeError(f"Topic {TOPIC} has no partitions")

    total_lag = 0

    for partition in sorted(partitions):
        tp = TopicPartition(TOPIC, partition)

        # Latest offset currently available on the broker
        end_offsets = consumer.end_offsets([tp])
        end_offset = end_offsets[tp]

        # Committed offset for this consumer group
        committed = consumer.committed(tp)

        if committed is None:
            committed = 0

        lag = max(0, end_offset - committed)
        total_lag += lag

    os.makedirs(os.path.dirname(REPORT), exist_ok=True)

    result = {
        "group": GROUP,
        "total_lag": total_lag
    }

    with open(REPORT, "w", encoding="utf-8") as f:
        json.dump(result, f, indent=2)
        f.write("\n")

    print("===== Kafka Lag Monitor =====")
    print(f"Broker:      {BOOTSTRAP}")
    print(f"Topic:       {TOPIC}")
    print(f"Group:       {GROUP}")
    print(f"Partitions:  {len(partitions)}")
    print(f"Total lag:   {total_lag}")
    print(f"Report:      {REPORT}")

finally:
    consumer.close()
PY

chmod +x /opt/labfiles/lag_monitor.py

echo "===== Running live lag monitor ====="
python3 /opt/labfiles/lag_monitor.py

echo
echo "===== Generated report ====="
cat /opt/labfiles/reports/lag-report.json

echo
echo "===== Report timestamp ====="
stat -c '%y %n' /opt/labfiles/reports/lag-report.json
```
