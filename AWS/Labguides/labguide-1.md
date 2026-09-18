# **Scenario 1: Parse Log File**

## **Overview**

In this assessment, you will use Linux shell scripting to automate log analysis tasks commonly performed by system administrators and support engineers. You will create a shell script that reads a preconfigured application log file, extracts error related entries, and generates a summary showing the total number of errors detected.

## **Scenario**

You have recently joined an IT Operations team as a Linux Support Engineer.

The organization hosts several business applications that generate log files containing important operational information. Support teams regularly review these logs to identify failures, troubleshoot incidents, and monitor application health.

Your manager has asked you to automate the log analysis process by creating a shell script that scans an application log file, extracts all error entries, and generates a summary report showing the total number of errors detected.

You have been provided access to a Linux virtual machine containing a preconfigured application log file and must create a shell script to perform the required analysis.

## **Environment Information**

Your working directory for this assessment is:

```bash
~/scripts
```

A sample application log file has been preconfigured on the virtual machine at:

```bash
/opt/logs/application.log
```

Sample entries in the file include:

```text
[error] Database connection failed
[error] Backend timeout
[error] Authentication failed
```

> Note: Do not modify the contents of the log file. Validation will verify the script against the existing log data.

## **Goal**

Create a shell script that reads the application log file, filters entries containing error messages, and displays both the matching entries and a summary count.

## **Required Outcome**

| Requirement | Details |
|---|---|
| Script name | `parse_logs.sh` |
| Location | `~/scripts` |
| Reads from | `/opt/logs/application.log` |
| Displays | All entries containing `[error]` |
| Displays | Total count of matching error entries |
| Permissions | Script must be executable |

After completing the task, click the **Validation** button.

<validation step="f2079934-22d9-4c29-b57a-b3d726ae0c8a" />

Click **Next** to begin Scenario 2.
