#!/bin/bash
# =====================================================================
# CloudLabs CSE bootstrap — Messaging & Eventing — Messaging Operations & Automation (Intermediate)
# Scope: real hands-on environment + validation for M1 (IBM MQ), M2 (Apache Kafka and
# KSQL), M4 (Ansible), and M5 (Python) — these are the four modules where a real,
# single-VM environment is practical (see Spec.md for the full VM-capacity rationale).
# M3, M6, M7 are question-only in this build; no Elastic/Logstash, Kubernetes, or
# Git/CI-CD infrastructure is deployed.
# M4 and M5 have no infrastructure of their own — they are tool-only modules that
# validate automation written against the M1/M2 containers already running here.
# Idempotent. Logs to /var/log/cloudlabs-bootstrap.log.
# =====================================================================
set -uo pipefail
exec > >(tee -a /var/log/cloudlabs-bootstrap.log) 2>&1
echo "[bootstrap] starting $(date -u)"

LABFILES=/opt/labfiles
STACK_DIR=$LABFILES/stack
REPORTS_DIR=$LABFILES/reports
mkdir -p "$LABFILES" "$STACK_DIR" "$REPORTS_DIR"

# ---------------------------------------------------------------------
# 1. Base packages
# ---------------------------------------------------------------------
echo "[bootstrap] installing base packages"
export DEBIAN_FRONTEND=noninteractive
# DEBIAN_FRONTEND above only suppresses debconf-style prompts. Ubuntu's needrestart
# package has its own SEPARATE interactive dialog (a whiptail "Daemons using
# outdated libraries / which services should be restarted?" prompt) that fires
# whenever an apt operation touches libraries used by running daemons, and is not
# controlled by DEBIAN_FRONTEND. In an interactive SSH session it just waits for
# Enter, but during actual bootstrap (no terminal attached) it can hang
# indefinitely waiting for input that will never come, silently stalling
# provisioning. Force it to automatic mode so it restarts affected services
# without ever prompting.
export NEEDRESTART_MODE=a
export NEEDRESTART_SUSPEND=1
apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release python3 python3-pip jq

# ---------------------------------------------------------------------
# 2. Docker + Compose plugin
# ---------------------------------------------------------------------
if ! command -v docker >/dev/null 2>&1; then
  echo "[bootstrap] installing Docker"
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  systemctl enable docker
  systemctl start docker
  usermod -aG docker azureuser 2>/dev/null || true
else
  echo "[bootstrap] Docker already present, skipping"
fi

# ---------------------------------------------------------------------
# 3. Ansible + Python libs (M4 and M5 are tool-only — no infra of their own,
#    they validate automation written against the M1/M2 containers below)
# ---------------------------------------------------------------------
if ! command -v ansible >/dev/null 2>&1; then
  echo "[bootstrap] installing Ansible"
  apt-get install -y ansible
fi
echo "[bootstrap] installing Python libraries"
pip3 install --quiet --break-system-packages kafka-python 2>/dev/null || pip3 install --quiet kafka-python

# kafka-python is a hard dependency for M5 (the attendee's lag-monitoring script
# imports it directly). Same failure mode as jq below: 'set -uo pipefail' means a
# silent pip/apt failure here would not stop the rest of bootstrap, and the
# attendee would only discover it mid-assessment as a bare ModuleNotFoundError.
# Verify python3-pip itself exists first (a missing pip means kafka-python could
# never have installed regardless of what the line above reported), then verify
# kafka-python specifically, retrying both if needed.
echo "[bootstrap] verifying pip3 and kafka-python installed correctly"
for i in $(seq 1 5); do
  command -v pip3 >/dev/null 2>&1 && break
  echo "[bootstrap] pip3 not found, retrying install ($i/5)"
  apt-get install -y python3-pip
  sleep 5
done
for i in $(seq 1 5); do
  python3 -c "import kafka" >/dev/null 2>&1 && break
  echo "[bootstrap] kafka-python not importable, retrying install ($i/5)"
  pip3 install --quiet --break-system-packages kafka-python 2>/dev/null || pip3 install --quiet kafka-python
  sleep 5
done
if ! python3 -c "import kafka" >/dev/null 2>&1; then
  echo "[bootstrap] FATAL: kafka-python could not be installed/imported after retries. M5's lag-monitoring script will fail with ModuleNotFoundError."
else
  echo "[bootstrap] kafka-python confirmed importable"
fi

# ---------------------------------------------------------------------
# 4. Docker Compose stack: Kafka + Zookeeper (M2) and IBM MQ (M1)
# ---------------------------------------------------------------------
echo "[bootstrap] writing docker-compose stack"
cat > "$STACK_DIR/docker-compose.yml" <<'EOF'
services:
  zookeeper:
    image: confluentinc/cp-zookeeper:7.6.1
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000
    ports: ["2181:2181"]

  kafka:
    image: confluentinc/cp-kafka:7.6.1
    depends_on: [zookeeper]
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:9092,PLAINTEXT_HOST://localhost:9094
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT
      KAFKA_INTER_BROKER_LISTENER_NAME: PLAINTEXT
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
      KAFKA_AUTO_CREATE_TOPICS_ENABLE: "false"
    ports: ["9094:9094"]

  ibmmq:
    image: icr.io/ibm-messaging/mq:latest
    environment:
      LICENSE: accept
      MQ_QMGR_NAME: QM1
      MQ_APP_PASSWORD: labpass123
    ports: ["1414:1414", "9443:9443"]
EOF

echo "[bootstrap] starting the stack"
cd "$STACK_DIR"
docker compose up -d

echo "[bootstrap] waiting for Kafka to accept connections"
for i in $(seq 1 30); do
  docker compose exec -T kafka kafka-topics --bootstrap-server localhost:9092 --list >/dev/null 2>&1 && break
  sleep 5
done

echo "[bootstrap] waiting for IBM MQ queue manager to be ready"
for i in $(seq 1 30); do
  docker compose exec -T ibmmq bash -c "echo 'DISPLAY QMGR' | runmqsc QM1" >/dev/null 2>&1 && break
  sleep 10
done

# ---------------------------------------------------------------------
# 5. Seed the M2 throughput topic (under-provisioned)
# ---------------------------------------------------------------------
echo "[bootstrap] seeding orders-events topic (under target partition count)"
docker compose exec -T kafka kafka-topics --bootstrap-server localhost:9092 \
  --create --if-not-exists --topic orders-events --partitions 2 --replication-factor 1

# ---------------------------------------------------------------------
# 6. Seed the M2/M5 message-loss/lag fault
# ---------------------------------------------------------------------
# Idempotency guard: this bootstrap script may run more than once on the same VM
# (manual re-runs during troubleshooting, or a platform-level retry of a failed
# CSE execution). Without this check, re-running the produce/consume block below
# would stack on top of prior runs — each rerun adds another 5000 messages while
# only advancing the committed offset by 1500, compounding lag by ~3500 per rerun
# instead of leaving a clean, deterministic ~3500 for the attendee. Skip seeding
# entirely if the consumer group already exists from a prior run.
if docker compose exec -T kafka kafka-consumer-groups --bootstrap-server localhost:9092 \
    --list 2>/dev/null | grep -q "^orders-consumers$"; then
  echo "[bootstrap] orders-consumers already exists, skipping fault seeding (idempotent)"
else
  echo "[bootstrap] seeding message-loss/lag fault"
  docker compose exec -T kafka bash -c '
    for i in $(seq 1 5000); do echo "order-$i,$(date +%s)"; done | \
    kafka-console-producer --bootstrap-server localhost:9092 --topic orders-events
  '
  # Consumer group consumes only the first 1500 messages then stops — leaves ~3500
  # lag/unread messages for the attendee to detect and resolve.
  docker compose exec -T kafka bash -c '
    timeout 10 kafka-console-consumer --bootstrap-server localhost:9092 --topic orders-events \
      --group orders-consumers --max-messages 1500 --from-beginning > /dev/null 2>&1 || true
  '
  echo "[bootstrap] fault seeded on group orders-consumers"
fi

# ---------------------------------------------------------------------
# 7. M1 target — PAYMENTS.QUEUE is left unseeded; creating it is the attendee's task
# ---------------------------------------------------------------------
echo "[bootstrap] QM1 is running; PAYMENTS.QUEUE creation is left as the attendee task for M1"

# ---------------------------------------------------------------------
# 8. M4 scaffold — Ansible starter playbook (checks M1 + M2 container state)
# ---------------------------------------------------------------------
echo "[bootstrap] seeding Ansible scaffold for combined broker health check"
mkdir -p "$LABFILES/ansible"
cat > "$LABFILES/ansible/inventory.ini" <<'EOF'
[local]
localhost ansible_connection=local
EOF
cat > "$LABFILES/ansible/broker-health-check.yml.sample" <<'EOF'
# BUILD NOTE / attendee task: this is a reference starting point, not the final file.
# Copy to broker-health-check.yml and complete it so that running it produces
# /opt/labfiles/reports/broker-health.json with keys: kafka_up and mq_up (each
# true/false, based on a real check of each container's running state — e.g. via
# community.docker.docker_container_info or a shell command like `docker inspect`).
---
- hosts: local
  tasks:
    - name: TODO - check kafka and ibmmq container state for real
      debug:
        msg: "replace with real checks"
EOF

# ---------------------------------------------------------------------
# 9. M5 note — kafka-python is installed above; report path only
# ---------------------------------------------------------------------
echo "[bootstrap] Python + kafka-python ready for M5 lag-monitoring script"

# ---------------------------------------------------------------------
# 10. Verify jq installed correctly. jq is a hard dependency for all four
#     validators (M1, M2, M4, M5 all parse JSON report files with it). Because
#     this script uses 'set -uo pipefail' rather than '-e', a single failed
#     package in step 1 would not stop the rest of bootstrap from running, and
#     jq could end up silently missing. Verify explicitly and retry before
#     finishing, so a bad apt run earlier can't silently break every validated
#     module later.
# ---------------------------------------------------------------------
echo "[bootstrap] verifying jq installed correctly"
for i in $(seq 1 5); do
  command -v jq >/dev/null 2>&1 && break
  echo "[bootstrap] jq not found, retrying install ($i/5)"
  apt-get install -y jq
  sleep 5
done
if ! command -v jq >/dev/null 2>&1; then
  echo "[bootstrap] FATAL: jq could not be installed after 5 attempts. Validators M1/M2/M4/M5 will not function correctly without it."
else
  echo "[bootstrap] jq confirmed installed: $(jq --version)"
fi

chown -R azureuser:azureuser "$LABFILES" 2>/dev/null || true
echo "[bootstrap] done $(date -u)"
