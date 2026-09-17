# --- Same values as deploy-01.parameters.json ---
azureUserName       = "GET-AZUSER-UPN"
azurePassword       = "GET-AZUSER-PASSWORD"
ODLID               = "GET-ODL-ID"
DeploymentID        = "GET-DEPLOYMENT-ID"
adminUsername       = "azureuser"
adminPassword       = "GEN-PASSWORD"
trainerUserName     = "instructor"
trainerUserPassword = "GEN-PASSWORD"

# --- Terraform-specific (no ARM equivalent — resourceGroup().location was implicit) ---
location = "East US"
