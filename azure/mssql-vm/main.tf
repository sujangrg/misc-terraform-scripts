variable "prefix" {
  default = "sgudb"
}


resource "azurerm_resource_group" "main" {
  name     = "sqlserver-rg"
  location = "australiaeast"
}


resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "RDP"
    priority                   = 3389
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "27.252.146.74"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-pip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
}


resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}


resource "azurerm_virtual_machine" "main" {
  name = "${var.prefix}-vm"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size = "Standard_B4ms"
  license_type = "Windows_Server"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftSQLServer"
    offer   = "SQL2017-WS2019"
    sku     = "SQLDEV"
    version = "latest"
  }

  storage_os_disk {
    name              = "${var.prefix}-db-disk"
    managed_disk_type = "StandardSSD_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name      = "${var.prefix}dbvm"
    admin_username     = "iamadmin"
    admin_password       = "MySecurePasswordhere"
  }

  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = false
    winrm {
      protocol = "http"
    }
  }
}

resource "azurerm_mssql_virtual_machine" "example" {
  virtual_machine_id = azurerm_virtual_machine.main.id
  sql_license_type   = "PAYG"
}


