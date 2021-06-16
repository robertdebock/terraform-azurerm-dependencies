output "public_ip_address-1" {
  value = data.azurerm_public_ip.publicip-1.ip_address
}

output "public_ip_address-2" {
  value = data.azurerm_public_ip.publicip-2.ip_address
}
