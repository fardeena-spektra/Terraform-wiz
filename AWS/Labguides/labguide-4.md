# **Scenario 4: Check Web Server Availability**

## **Overview**

In this assessment, you will create a shell script that verifies whether a web server is available and responding to requests.

## **Scenario**

You have recently joined the Linux Operations team as a System Administrator.

The organization hosts several web based applications that depend on the Apache HTTP Server (HTTPD). To ensure that these applications remain accessible, administrators regularly verify that the web server is running and responding correctly.

Your manager has asked you to create a shell script that checks the availability of the local web server and reports whether the service is accessible.

You have been provided access to a Linux virtual machine with Apache HTTP Server already installed and configured.

## **Environment Information**

Your working directory for this assessment is:

```bash
~/scripts
```

## **Goal**

Create a shell script that uses the `curl` command to check whether the local web server is responding, and displays a status message based on the result.

## **Required Outcome**

| Requirement | Details |
|---|---|
| Script name | `check_server.sh` |
| Location | `~/scripts` |
| Method | Uses `curl` to check `http://localhost` |
| Success message | `Server is available` |
| Failure message | `Server is unavailable` |
| Permissions | Script must be executable |

After completing the task, click the **Validation** button.

<validation step="31bcf261-df44-4636-ac7f-d7a4f776d17c" />

Click **Next** to begin Scenario 5.
