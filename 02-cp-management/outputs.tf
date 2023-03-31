output "mgmt-ip" {
    value = azurerm_public_ip.public-ip.ip_address
}
output "mgmt-pass" {
    value = var.admin_password
    sensitive = true
}

output "mgmt-login-pwsh" {
    value = "terraform output -raw mgmt-pass | clip; ssh admin@${azurerm_public_ip.public-ip.ip_address}"
    sensitive = true
}