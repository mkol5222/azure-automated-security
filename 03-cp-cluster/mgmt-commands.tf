



output "cluster-eth0" {
  value = azurerm_network_interface.nic_vip.ip_configuration[1].private_ip_address
}

output "node1-eth0" {
  value = azurerm_network_interface.nic_vip.ip_configuration[0].private_ip_address
}


output "node2-eth0" {
  value = azurerm_network_interface.nic.ip_configuration[0].private_ip_address
}


output "node1-eth1" {
  value = azurerm_network_interface.nic1[0].ip_configuration[0].private_ip_address
}
output "node2-eth1" {
  value = azurerm_network_interface.nic1[1].ip_configuration[0].private_ip_address
}


output "front-subnet-netmask" {
  value = cidrnetmask(data.azurerm_subnet.frontend.address_prefix)
}

output "back-subnet-netmask" {
  value = cidrnetmask(data.azurerm_subnet.backend.address_prefix)
}


output "sic-key" {
  value = var.sic_key
}


output "node1-public" {
  value = azurerm_public_ip.public-ip[0].ip_address
}
output "node2-public" {
  value = azurerm_public_ip.public-ip[1].ip_address
}
output "cluster-public" {
  value = azurerm_public_ip.cluster-vip.ip_address
}
output "cp-pass" {
  value = var.admin_password
}
locals {
    node1-pub-pip = azurerm_public_ip.public-ip[0].ip_address
    node2-pub-pip = azurerm_public_ip.public-ip[1].ip_address
}

output "cmd-login-node1" {
    value = "terraform output -raw cp-pass | Set-Clipboard;  ssh admin@${local.node1-pub-pip}"
    
}

output "cmd-login-node2" {
    value = "terraform output -raw cp-pass | Set-Clipboard;  ssh admin@${local.node2-pub-pip}"
    
}


output "mgmt-commands" {
  value = templatefile(
    "${path.module}/mgmt-commands.tftpl",
    {

      CLUSTER_NAME  = var.cluster_name
      VERSION       = var.os_version
      PUBLIC_VIP    = azurerm_public_ip.cluster-vip.ip_address
      VIP_ETH0_IP   = azurerm_network_interface.nic_vip.ip_configuration[1].private_ip_address // cluster-eth0
      FRONT_NETMASK = cidrnetmask(data.azurerm_subnet.frontend.address_prefix)
      SIC_KEY       = var.sic_key
      NODE1_ETH0_IP = azurerm_network_interface.nic_vip.ip_configuration[0].private_ip_address
      NODE1_ETH1_IP = azurerm_network_interface.nic1[0].ip_configuration[0].private_ip_address
      BACK_NETMASK  = cidrnetmask(data.azurerm_subnet.backend.address_prefix)
      NODE2_ETH0_IP = azurerm_network_interface.nic.ip_configuration[0].private_ip_address
      NODE2_ETH1_IP = azurerm_network_interface.nic1[1].ip_configuration[0].private_ip_address
    }
  )
}