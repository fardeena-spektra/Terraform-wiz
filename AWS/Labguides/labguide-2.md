# **Scenario 2: Monitor Service and Restart**

## **Overview**

In this assessment, you will use Linux shell scripting to monitor and manage system services. You will verify the status of the Apache HTTP Server (HTTPD), simulate a service outage by stopping the service, and then create a shell script that automatically detects and starts the service when it is not running.

## **Scenario**

You have recently joined an Infrastructure Operations team as a Linux Administrator.

The organization hosts several business applications that depend on the Apache HTTP Server (HTTPD) to deliver web content. Service interruptions can impact application availability and user experience.

Your manager has asked you to verify the status of the HTTPD service, simulate a service outage, and develop a monitoring script that automatically starts the service whenever it is found to be stopped.

You have been provided access to a Linux virtual machine with HTTPD preinstalled and configured.

## **Environment Information**

Your working directory for this assessment is:

```bash
~/scripts
```

Use the `systemctl` or `service` command to check the status of the HTTPD service.

## **Task 1: Stop the HTTPD Service**

### Goal

Manually stop the HTTPD service and verify that it is no longer running.

### Required Outcome

| Requirement | Details |
|---|---|
| Starting state | Service verified as running |
| Action | Service stopped |
| Ending state | Service status shows `inactive` |

After completing the task, click the **Validation** tab.

<validation step="dfb21bdb-d7ab-4a73-88b8-9123867891d8" />

## **Task 2: Create a Service Monitoring Script**

> Note: Follow the specified file names and paths exactly to ensure validation succeeds.

### Goal

Create a shell script that checks whether the HTTPD service is running and automatically starts it if it is stopped.

### Required Outcome

| Requirement | Details |
|---|---|
| Script name | `monitor_service.sh` |
| Location | `~/scripts` |
| Service checked | `httpd` |
| Behaviour | Starts the service if it is not running, and displays an appropriate status message |
| Permissions | Script must be executable |
| Ending state | Service is `active` after running the script |

After completing the task, click the **Validation** tab.

<validation step="0d980599-73b0-41a3-b768-87c5c004307d" />

Click **Next** to begin Scenario 3.
