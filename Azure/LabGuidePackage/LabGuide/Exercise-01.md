# **Scenario 1: Configure and Verify the Payments Queue**

### Module 1 - IBM MQ

## **Overview**

A new payments processing flow needs a dedicated queue on the existing MQ infrastructure. Upstream and downstream applications will exchange transaction messages through it, and nothing is provisioned yet. You are setting this up from a clean queue manager.

This is an **assessment**: the task gives you the **required outcome** and the **exact conditions** the validator checks, not the steps. Work the IBM MQ tooling yourself, then press **Validate** to score it.

> **Note:** IBM MQ runs as a container on this VM. Log into it and work from inside: `cd /opt/labfiles/stack && docker compose exec -it ibmmq bash`. Queue manager name: `QM1`. IBM MQ's sample client programs (including put/get utilities) are located at `/opt/mqm/samp/bin` and are not on the default `$PATH`. Type `exit` when done to return to the VM shell.

## **Task 1: Provision and verify the payments queue**

**Goal:** Create a queue that upstream and downstream payments applications can reliably exchange messages through, and prove it actually works before moving on.

**Required outcome:**

- A local queue named **`PAYMENTS.QUEUE`** exists on queue manager **`QM1`**.
- A message placed onto `PAYMENTS.QUEUE` can be successfully retrieved, a working put/get round trip, not just an empty queue definition.

The validator independently places a probe message onto `PAYMENTS.QUEUE` and confirms it can retrieve that same message back, so the queue needs to be genuinely open and usable, not just present in the queue manager's object list.

> **Congratulations** on completing the task! Now, it's time to validate it. Here are the steps:
> - Hit the Validate button for the corresponding task. If you receive a success message, you can proceed to the next task.
> - If not, carefully read the error message and retry the step, following the instructions in the guide.
> - If you need any assistance, please contact us at labs-support@spektrasystems.com. We are available 24/7 to help you out.

<validation step="8f99482f-3ee1-442b-99e6-320a0fa13bb2" />

Click **Next** to begin Scenario 2.

