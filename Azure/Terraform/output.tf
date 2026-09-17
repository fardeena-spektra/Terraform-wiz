# ---------------------------------------------------------------------------
# Outputs (equivalent to ARM template "outputs")
# ---------------------------------------------------------------------------

output "DeploymentID" {
  description = "Deployment ID"
  value       = var.DeploymentID
}

output "LabVMAdminUsername" {
  description = "LabVM Admin Username"
  value       = var.adminUsername
}

output "LabVMAdminPassword" {
  description = "LabVM Admin Password"
  value       = var.adminPassword
  sensitive   = true
}

output "LabVMDNSName" {
  description = "LabVM DNS Name"
  value       = azurerm_public_ip.pip.fqdn
}

output "LabVMSSHCommand" {
  description = "LabVM SSH Command"
  value       = "ssh ${var.adminUsername}@${azurerm_public_ip.pip.fqdn}"
}

output "location" {
  description = "Azure region resources were deployed into"
  value       = azurerm_resource_group.rg.location
}
