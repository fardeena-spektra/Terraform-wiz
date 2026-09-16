# --- AWS provider auth (required for terraform to authenticate) ---
aws_region = "us-east-1"
AccessKey  = "GET-ACCESS-KEY"
SecretKey  = "GET-SECRET-KEY"

# --- Lab-specific parameters (same as parameters.json) ---
CloudLabsDeploymentID = "GET-DEPLOYMENT-ID"
CheckAcknowledgement  = "TRUE"
vpcCidr               = "10.10.0.0/16"
subnetCidr            = "10.10.0.0/24"
VMUserName            = "Labuser"
VMPassword            = "GEN-PASSWORD"
