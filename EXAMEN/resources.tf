resource "azurerm_resource_group" "examen" {
  name     = "${var.prefijo}-resource"
  location = var.location
}

resource "azurerm_virtual_network" "examen" {
  name                = "${var.prefijo}-network"
  address_space       = ["10.0.0.0/24"]
  location            = azurerm_resource_group.examen.location
  resource_group_name = azurerm_resource_group.examen.name
}

resource "azurerm_subnet" "examen" {
  name                 = "internal1"
  resource_group_name  = azurerm_resource_group.examen.name
  virtual_network_name = azurerm_virtual_network.examen.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_interface" "examen" {
  name                = "interface1"
  location            = azurerm_resource_group.examen.location
  resource_group_name = azurerm_resource_group.examen.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.examen.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.examen.id
  }
}


resource "azurerm_windows_virtual_machine" "examen" {
  name                = "vm-mbo"
  resource_group_name = azurerm_resource_group.examen.name
  location            = "centralus"
  size                = "Standard_D2as_v5"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.examen.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}


/*ASIGNACION DE RECURSOS ADICIONALES PARA DESPLEGAR VIRTUAL MACHINE*/


resource "azurerm_public_ip" "examen" {
    name = "${var.prefijo}-myPublicIP"
    location = azurerm_resource_group.examen.location
    resource_group_name = azurerm_resource_group.examen.name
    allocation_method = "Dynamic"
}
resource "azurerm_network_security_group" "examen" {
    name = "acceptanceTestSecurityGroup1-${var.prefijo}"
    location = azurerm_resource_group.examen.location
    resource_group_name = azurerm_resource_group.examen.name
}
resource "azurerm_network_security_rule" "examen" {
    name = "${var.prefijo}-security-rule"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "3389"
    source_address_prefix = "*"
    destination_address_prefix = "*"
    resource_group_name = azurerm_resource_group.examen.name
    network_security_group_name = azurerm_network_security_group.examen.name
}
resource "azurerm_network_interface_security_group_association" "examen" {
    network_interface_id = azurerm_network_interface.examen.id
    network_security_group_id = azurerm_network_security_group.examen.id
}

