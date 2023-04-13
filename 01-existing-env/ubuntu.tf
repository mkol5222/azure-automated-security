# Create public IPs
resource "azurerm_public_ip" "public_ip" {
  name                = "u1-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"

  tags = {
    environment = "azure-demo"
  }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = "u1-ngs"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "Web"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
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

# Create network interface
resource "azurerm_network_interface" "nic" {
  depends_on = [
    azurerm_subnet.linux-subnet
  ]
  name                = "u1-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.linux-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }

}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.rg.name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "storage" {
  name                     = "diag${random_id.randomId.hex}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }

}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
  #   keepers = {
  #   # Generate a new ID only when a new resource group is defined
  #   resource_group = azurerm_resource_group.rg.name
  # }
  #  lifecycle {
  #   replace_triggered_by = [
  #     # Replace `aws_appautoscaling_target` each time this instance of
  #     # the `aws_ecs_service` is replaced.
  #     azurerm_linux_virtual_machine.linuxvm
  #   ]
  # }
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "linuxvm" {
  name                  = "ubuntu1"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "ubuntu1"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.example_ssh.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.storage.primary_blob_endpoint
  }
  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }

}


variable "route_through_firewall" {
  default     = false
  description = "create route from Linux segment through firewall VNA"
}

resource "azurerm_route_table" "linux-rt" {
  name                          = "linux-rt-tf"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  disable_bgp_route_propagation = false

  route {
    name                   = "to-aks1"
    address_prefix         = "10.42.1.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.42.4.47"
  }
  route {
    name           = "route-to-my-pub-ip"
    address_prefix = "${data.http.myip.response_body}/32"
    next_hop_type  = "Internet"
  }
  dynamic "route" {
    for_each = var.route_through_firewall ? [1] : []
    content {
      name                   = "to-internet"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = "10.42.4.47"
    }
  }


  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }

}

resource "azurerm_subnet_route_table_association" "linux-rt-to-subnet" {
  subnet_id      = azurerm_subnet.linux-subnet.id
  route_table_id = azurerm_route_table.linux-rt.id
}

output "u1_ssh_ip" {

  value = azurerm_linux_virtual_machine.linuxvm.public_ip_address
}

output "u1_ssh_key" {
  value     = tls_private_key.example_ssh.private_key_pem
  sensitive = true
}
output "u1_ssh_key_pub" {
  value     = tls_private_key.example_ssh.public_key_openssh
  sensitive = true
}
output "u1_ssh_config" {
  value = <<-EOT
  Host u1aas
    HostName ${azurerm_linux_virtual_machine.linuxvm.public_ip_address}
    User azureuser
    IdentityFile ~/.ssh/config.d/u1aas.key
  EOT
}
# output "u1_setup_pwsh" {
#   value = <<-EOT
#   terraform output -raw u1_ssh_key | Out-File -Encoding ASCII  $env:USERPROFILE/.ssh/config.d/u1aas.key
#   terraform output -raw u1_ssh_config | Out-File -Encoding ASCII $env:USERPROFILE/.ssh/config.d/u1aas.conf
#   EOT
# }
output "u1_setup_bash" {
  value = <<-EOT
  mkdir ~/.ssh/config.d/
  grep -qxF 'Include config.d/*.conf' ~/.ssh/config || sed -i '$ a\Include config.d/*.conf' ~/.ssh/config
  chmod u=rw ~/.ssh/config.d/u1aas.key
  terraform output -raw u1_ssh_key > ~/.ssh/config.d/u1aas.key
  terraform output -raw u1_ssh_config > ~/.ssh/config.d/u1aas.conf
  chmod 400 ~/.ssh/config.d/u1aas.key
  # echo 'Make sure you Include config.d/*.conf in your ~/.ssh/config'
  EOT
}

