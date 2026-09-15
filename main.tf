terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id
}

# ---------------------------------------------------------------------------
# Variables (equivalent to ARM "parameters")
# ---------------------------------------------------------------------------

variable "azure_client_id" {
  type = string
}

variable "azure_client_secret" {
  type      = string
  sensitive = true
}

variable "azure_subscription_id" {
  type = string
}

variable "azure_tenant_id" {
  type = string
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "resource_group_name" {
  description = "Existing resource group to deploy into (equivalent to ARM's resourceGroup().location scope)"
  type        = string
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
  type      = string
  sensitive = true
}

# ---------------------------------------------------------------------------
# Locals (equivalent to ARM "variables")
# ---------------------------------------------------------------------------

locals {
  scripturl       = "https://experienceazure.blob.core.windows.net/templates/microland/Cloud-Azure-Powershell-Ansible-windows-and-Linux-Assessment-1/bootv1.ps1"
  commonscripturl = "https://experienceazure.blob.core.windows.net/templates/cloudlabs-common/cloudlabs-windows-functions.ps1"

  lab_vm_name              = "labvm-${var.DeploymentID}"
  vm_size                  = "Standard_D2as_v5"
  network_interface_name   = "${local.lab_vm_name}-nic"
  public_ip_address_name   = "${local.lab_vm_name}-pip"
  public_ip_address_dns    = "lab${var.DeploymentID}vm${lower(random_string.dns_suffix.result)}"
  network_security_group_n = "${local.lab_vm_name}-nsg"
  virtual_network_name     = "${local.lab_vm_name}-vnet"
}

# ---------------------------------------------------------------------------
# Existing resource group (ARM deployed "into" the RG, not create one)
# ---------------------------------------------------------------------------

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# Equivalent to ARM's uniqueString(resourceGroup().id) - guarantees a unique DNS label
resource "random_string" "dns_suffix" {
  length  = 8
  special = false
  upper   = false
}

# ---------------------------------------------------------------------------
# Networking
# ---------------------------------------------------------------------------

resource "azurerm_virtual_network" "vnet" {
  name                = local.virtual_network_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = local.public_ip_address_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = local.public_ip_address_dns
}

resource "azurerm_network_security_group" "nsg" {
  name                = local.network_security_group_n
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name

  security_rule {
    name                       = "default-allow-rdp"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic" {
  name                = local.network_interface_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id     = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# ---------------------------------------------------------------------------
# Virtual Machine
# ---------------------------------------------------------------------------

resource "azurerm_windows_virtual_machine" "labvm" {
  name                = local.lab_vm_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  size                = local.vm_size
  admin_username      = var.adminUsername
  admin_password      = var.adminPassword

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  os_disk {
    name                 = "${local.lab_vm_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "custom_script" {
  name                       = "CustomScript"
  virtual_machine_id         = azurerm_windows_virtual_machine.labvm.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.10"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    fileUris = [
      local.scripturl,
      local.commonscripturl
    ]
  })

  protected_settings = jsonencode({
    commandToExecute = "powershell -ExecutionPolicy Unrestricted -File microland/Cloud-Azure-Powershell-Ansible-windows-and-Linux-Assessment-1/bootv1.ps1 -DeploymentID ${var.DeploymentID} -trainerUserName ${var.trainerUserName} -trainerUserPassword ${var.trainerUserPassword}"
  })
}

# ---------------------------------------------------------------------------
# Outputs (equivalent to ARM "outputs")
# ---------------------------------------------------------------------------

output "DeploymentID" {
  value = var.DeploymentID
}

output "LabVM_Admin_Username" {
  value = var.adminUsername
}

output "LabVM_Admin_Password" {
  value     = var.adminPassword
  sensitive = true
}

output "LabVM_DNS_Name" {
  value = azurerm_public_ip.pip.fqdn
}

output "LabVM_RDP_Command" {
  value = "mstsc /v:${azurerm_public_ip.pip.fqdn}"
}

output "location" {
  value = var.location
}
