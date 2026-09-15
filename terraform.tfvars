# --- CloudLabs / Azure provider auth (required for terraform to authenticate) ---
azure_client_id       = "GET-SUBSCRIPTION-CLIENT-ID"
azure_client_secret   = "GET-SUBSCRIPTION-CLIENT-SECRET"
azure_subscription_id = "GET-SUBSCRIPTION-GUID"
azure_tenant_id       = "GET-TENANT-GUID"
location              = "eastus"
resource_group_name   = "GET-RESOURCE-GROUP-NAME"

# --- Lab-specific parameters (same as parameters.json) ---
azureUserName        = "GET-AZUSER-UPN"
azurePassword        = "GET-AZUSER-PASSWORD"
ODLID                = "GET-ODL-ID"
DeploymentID         = "GET-DEPLOYMENT-ID"
adminUsername        = "azureuser"
adminPassword        = "GEN-PASSWORD"
trainerUserName      = "instructor"
trainerUserPassword  = "GEN-PASSWORD"
