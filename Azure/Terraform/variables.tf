# ---------------------------------------------------------------------------
# Variables (equivalent to ARM template "parameters")
# ---------------------------------------------------------------------------

variable "location" {
  description = "Azure region to deploy into (ARM template relied on resourceGroup().location)"
  type        = string
  default     = "East US"
}

variable "azureUserName" {
  type = string
}

variable "azurePassword" {
  type      = string
  sensitive = true
}

variable "ODLID" {
  type = string
}

variable "DeploymentID" {
  type = string
}

variable "adminUsername" {
  type = string
}

variable "adminPassword" {
  type      = string
  sensitive = true
}

variable "trainerUserName" {
  type = string
}

variable "trainerUserPassword" {
  type = string
}
