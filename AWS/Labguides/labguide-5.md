# **Scenario 5: Use Exit Codes and Debugging**

## **Overview**

In this assessment, you will create a shell script that verifies whether a file exists and returns appropriate exit codes based on the result.

## **Scenario**

You have recently joined a Linux Operations team as a Junior System Administrator.

The organization uses shell scripts to automate routine administrative tasks and relies on exit codes to determine whether those tasks complete successfully. Automated monitoring systems review these exit codes and trigger alerts whenever failures occur.

Your manager has asked you to create a shell script that verifies the existence of a specific file and returns different exit codes depending on whether the file is present or missing.

You have been provided access to a Linux virtual machine containing a preconfigured file that must be validated.

## **Environment Information**

Your working directory for this assessment is:

```bash
~/scripts
```

A sample file has been preconfigured for this assessment at:

```bash
/opt/data/testfile.txt
```

## **Goal**

Create a shell script that checks whether a specific file exists, displays an appropriate message, and returns a different exit code depending on the result.

## **Required Outcome**

| Requirement | Details |
|---|---|
| Script name | `file_check.sh` |
| Checks for | `/opt/data/testfile.txt` |
| If file exists | Displays `File exists.` and returns exit code `0` |
| If file is missing | Displays `File not found.` and returns exit code `1` |
| Permissions | Script must be executable |

After completing the task, click the **Validation** button.

<validation step="33df1f62-1141-4bc2-bf22-cecb8bf6abe3" />

# **Congratulations! You have successfully completed the assignment.**
# **Please click End Lab to complete the assessment.**
