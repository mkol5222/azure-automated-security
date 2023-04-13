// az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/SUBSCRIPTION_ID"

data "http" "myip" {
  url = "http://ip.iol.cz/ip/"
}

output "myip" {
  value = data.http.myip.response_body
}

resource "azurerm_resource_group" "rg" {
  name     = var.vnet_resource_group
  location = var.location

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = ["10.42.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }
}

resource "azurerm_subnet" "linux-subnet" {
  name                 = "linux-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.42.5.0/24"]
}

resource "azurerm_subnet" "aks-subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.42.1.0/24"]
}

resource "azurerm_subnet" "cp-back" {
  name                 = "cp-back-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.42.4.0/24"]
}
resource "azurerm_subnet" "cp-front" {
  name                 = "cp-front-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.42.3.0/24"]
}

variable "management_subnet_name" {
  description = "subnet for management VM"
  default = "net-mgmt"
}
variable "management_subnet_address" {
  description = "subnet for management VM address - e.g. 10.42.99.0/24"
  default = "10.42.99.0/24"
}
resource "azurerm_subnet" "net-mgmt" {
  name                 = var.management_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.management_subnet_address]
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "front-nsg" {
  name                = "front-ngs"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowAllIncoming"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }
}

resource "azurerm_subnet_network_security_group_association" "front-nsg-asoc" {
  subnet_id                 = azurerm_subnet.cp-front.id
  network_security_group_id = azurerm_network_security_group.front-nsg.id
}