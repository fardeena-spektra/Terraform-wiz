terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}
}

# ---------------------------------------------------------------------------
# Locals (equivalent to ARM template "variables")
# ---------------------------------------------------------------------------

locals {
  scripturl                   = "https://experienceazure.blob.core.windows.net/templates/Nedbank/assessmentlabs/nedbank-eventing-and-messaging-intermediate-assessment/DeploymentPackage/bootstrap-01.sh"
  lab_vm_name                 = "labvm-${var.DeploymentID}"
  vm_size                     = "Standard_D2s_v3"
  network_interface_name      = "${local.lab_vm_name}-nic"
  public_ip_address_name      = "${local.lab_vm_name}-pip"
  public_ip_address_dns_name  = "lab${var.DeploymentID}vm${random_string.unique.result}"
  network_security_group_name = "${local.lab_vm_name}-nsg"
  virtual_network_name        = "${local.lab_vm_name}-vnet"
}

# uniqueString(resourceGroup().id) equivalent
resource "random_string" "unique" {
  length  = 13
  special = false
  upper   = false
}

# ---------------------------------------------------------------------------
# Resource Group
# ---------------------------------------------------------------------------

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.DeploymentID}"
  location = var.location
}

# ---------------------------------------------------------------------------
# Networking
# ---------------------------------------------------------------------------

resource "azurerm_virtual_network" "vnet" {
  name                = local.virtual_network_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = local.public_ip_address_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = local.public_ip_address_dns_name
}

resource "azurerm_network_security_group" "nsg" {
  name                = local.network_security_group_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "default-allow-ssh"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic" {
  name                = local.network_interface_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# ---------------------------------------------------------------------------
# Virtual Machine
# ---------------------------------------------------------------------------

resource "azurerm_linux_virtual_machine" "lab_vm" {
  name                            = local.lab_vm_name
  computer_name                   = local.lab_vm_name
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  size                            = local.vm_size
  admin_username                  = var.adminUsername
  admin_password                  = var.adminPassword
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.nic.id]

  os_disk {
    name                 = "${local.lab_vm_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 64
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "custom_script" {
  name                       = "CustomScript"
  virtual_machine_id         = azurerm_linux_virtual_machine.lab_vm.id
  publisher                  = "Microsoft.Azure.Extensions"
  type                       = "CustomScript"
  type_handler_version       = "2.1"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    fileUris = [local.scripturl]
  })

  protected_settings = jsonencode({
    commandToExecute = "bash bootstrap-01.sh -d ${var.DeploymentID} -u ${var.trainerUserName} -p ${var.trainerUserPassword}"
  })
}
