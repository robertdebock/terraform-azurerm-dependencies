# Add a resource group..
resource "azurerm_resource_group" "rg" {
  name     = "rg-robertdebock-sbx"
  location = var.location
}

# Create a virtual network.
resource "azurerm_virtual_network" "vnet" {
  name                = "myTFVnet-robert"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "myTFSubnet-robert"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IP
resource "azurerm_public_ip" "publicip-1" {
  name                = "myTFPublicIP-robert-1"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# Create public IP
resource "azurerm_public_ip" "publicip-2" {
  name                = "myTFPublicIP-robert-2"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = "myTFNSG-robert"
  location            = var.location
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
}

# Create network interface
resource "azurerm_network_interface" "nic-1" {
  name                = "myNIC-robert-1"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myNICConfg-robert"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip-1.id
  }
}

# Create network interface
resource "azurerm_network_interface" "nic-2" {
  name                = "myNIC-robert-2"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myNICConfg-robert"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip-2.id
  }
}

# Create a Linux virtual machine
resource "azurerm_virtual_machine" "vm-1" {
  name                  = "myTFVM-robert-1"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic-1.id]
  vm_size               = var.vm_size[var.size]

  storage_os_disk {
    name              = "myOsDisk-robert-1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "myTFVM-robert"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

# Create a Linux virtual machine
resource "azurerm_virtual_machine" "vm-2" {
  name                  = "myTFVM-robert-2"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic-2.id]
  vm_size               = var.vm_size[var.size]

  storage_os_disk {
    name              = "myOsDisk-robert-2"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "myTFVM-robert"
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
  depends_on = [azurerm_virtual_machine.vm-1]
}

data "azurerm_public_ip" "publicip-1" {
  name                = azurerm_public_ip.publicip-1.name
  resource_group_name = azurerm_virtual_machine.vm-1.resource_group_name
  depends_on          = [azurerm_virtual_machine.vm-1]
}

data "azurerm_public_ip" "publicip-2" {
  name                = azurerm_public_ip.publicip-2.name
  resource_group_name = azurerm_virtual_machine.vm-2.resource_group_name
  depends_on          = [azurerm_virtual_machine.vm-2]
}
