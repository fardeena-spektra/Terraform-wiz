# **Scenario 3: Automate Script Execution Using Cron**

## **Overview**

In this assessment, you will create a shell script that generates a simple system report and configure a cron job to execute the script automatically at scheduled intervals.

## **Scenario**

You have recently joined the Linux Operations team as a System Administrator.

The organization requires automated system reporting to help monitor server activity and maintain historical records of system events. Your manager has requested that you create a shell script that records the current date and time into a log file and then schedule the script to execute automatically using cron.

You have been provided access to a Linux virtual machine and must complete the reporting automation solution.

## **Environment Information**

Your working directory for this assessment is:

```bash
~/scripts
```

## **Task 1: Create a Scheduled Reporting Script**

### Goal

Create a shell script that appends the current date and time to a log file each time it runs.

### Required Outcome

| Requirement | Details |
|---|---|
| Script name | `system_report.sh` |
| Location | `~/scripts` |
| Writes to | `/tmp/system_report.log` |
| Behaviour | Appends the current date and time on each run |
| Permissions | Script must be executable |

After completing the task, click the **Validation** button.

<validation step="65ec2094-7768-48a6-a5fa-2a714c795f49" />

## **Task 2: Configure a Cron Job**

### Goal

Schedule the reporting script to run automatically without manual intervention.

### Required Outcome

| Requirement | Details |
|---|---|
| Script scheduled | `/home/Labuser/scripts/system_report.sh` |
| Frequency | Every minute |
| Verification | New timestamp entries appear in `/tmp/system_report.log` over time without manual execution |

After completing the task, click the **Validation** button.

<validation step="1be7e975-2f79-4a15-af99-35df686db6cc" />

Click **Next** to begin Scenario 4.
