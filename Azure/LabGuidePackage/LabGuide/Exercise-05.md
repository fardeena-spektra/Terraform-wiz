# **Scenario 5: Build a Programmatic Lag Monitor**

### Module 5 - Python

## **Overview**

Manually checking consumer lag isn't sustainable for ongoing operations. You need a script that measures it programmatically, reading real state from the live broker, so it can be run on demand or scheduled going forward.

This is an **assessment**: the task gives you the **required outcome** and the **exact conditions** the validator checks, not the steps. Write the script yourself, then press **Validate** to score it.

> **Note:** This scenario runs directly on the VM host. Python 3.10 and `kafka-python` 3.0.11 are already installed, no container login is required. Check `pip show kafka-python` if you need to confirm the exact API your installed version supports, since some parameters differ across `kafka-python` releases. Kafka exposes a host-accessible listener at `localhost:9094` for scripts running outside its container. The Kafka CLI tools...

## **Task 1: Write and run a live lag-monitoring script**

**Goal:** Produce a script that connects to the live broker and reports the true current lag for `orders-consumers`, not a fixed or estimated value.

**Required outcome:**

- Running your script writes **`/opt/labfiles/reports/lag-report.json`** with keys **`group`** (set to `orders-consumers`) and **`total_lag`** (the calculated value).
- `total_lag` must be **below 100**, reflecting that the underlying backlog has actually been resolved, not just that the script runs without error.

The validator reads the same live broker state your script does, so `total_lag` can only report a low value once the actual consumer group backlog is genuinely cleared. The report also has to be recent (produced within the last 20 minutes) and the group name must match exactly.

> **Congratulations** on completing the task! Now, it's time to validate it. Here are the steps:
> - Hit the Validate button for the corresponding task. If you receive a success message, you can proceed to the next task.
> - If not, carefully read the error message and retry the step, following the instructions in the guide.
> - If you need any assistance, please contact us at labs-support@spektrasystems.com. We are available 24/7 to help you out.

<validation step="a156d0d5-7000-4329-a71c-af2e55e928bb" />

Click **Next** to begin Scenario 6.



