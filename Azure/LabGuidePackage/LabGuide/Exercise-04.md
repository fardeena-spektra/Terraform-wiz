# **Scenario 4: Automate Cross-Service Health Verification**

### Module 4 - Ansible

## **Overview**

Operations has no automated way to confirm both the Kafka broker and the IBM MQ queue manager are genuinely up at any given moment. You need to build that check yourself, and it needs to reflect real state, not a fixed or assumed result.

This is an **assessment**: the task gives you the **required outcome** and the **exact conditions** the validator checks, not the steps. Write the automation yourself, then press **Validate** to score it.

> **Note:** This scenario runs directly on the VM host. Ansible is already installed, no container login is required. Working directory: `/opt/labfiles/ansible`. Inventory file: `inventory.ini`. A starting scaffold is provided at `broker-health-check.yml.sample`; copy it before editing. The two services you are checking run as Docker containers on this same VM, confirm their exact container names with `docker ps` before referencing them in your playbook, since Docker Compose does not always name containers after the plain service name. If you check container state using `docker inspect` with its Go-template syntax (`{{.State.Running}}`) inside an Ansible `command` or `shell` task, Ansible's own Jinja2 templating will try to parse that syntax and error, escape it (e.g. with `{% raw %}...{% endraw %}`) or use a module that avoids raw Go-template syntax entirely, such as `community.docker.docker_container_info`.

## **Task 1: Build and run a real cross-service health check**

**Goal:** Produce automation that determines the true running state of both the Kafka and IBM MQ containers, and publishes the result to a report file.

**Required outcome:**

- Running your automation writes **`/opt/labfiles/reports/broker-health.json`** with keys **`kafka_up`** and **`mq_up`**, each set to `true` or `false`.
- Both values must **accurately reflect the containers' real running state** at the time the automation ran.

The validator does not simply trust the file's contents. It independently checks each container's actual state itself and compares that against what your automation reported. A hardcoded or assumed result will fail the moment it disagrees with reality, and the report also has to be recent (produced within the last 20 minutes), so a stale file from an earlier run will not pass either.

> **Congratulations** on completing the task! Now, it's time to validate it. Here are the steps:
> - Hit the Validate button for the corresponding task. If you receive a success message, you can proceed to the next task.
> - If not, carefully read the error message and retry the step, following the instructions in the guide.
> - If you need any assistance, please contact us at labs-support@spektrasystems.com. We are available 24/7 to help you out.

<validation step="cb594a0f-c7b0-4f6d-a8f8-c158e0b9d917" />

Click **Next** to begin Scenario 5.


