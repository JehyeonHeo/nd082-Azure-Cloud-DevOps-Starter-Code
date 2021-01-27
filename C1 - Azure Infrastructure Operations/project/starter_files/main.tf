provider "azurerm" {
  features {}
}

data "azurerm_image" "search" {
  name                = "myPackerImage"
  resource_group_name = "AzureWebServerTry"
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = var.location
  tags = {
    project = "AzureWebServerDeploy"
  }
}

resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-public-ip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"

  tags = {
    project = "AzureWebServerDeploy"
  }
}

resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-network-security-group"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    project = "AzureWebServerDeploy"
  }
}

resource "azurerm_network_security_rule" "main1" {
  name                        = "AllowVnetInBound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_network_security_rule" "main2" {
  name                        = "AllowAzureLoadBalancerInBound"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_network_security_rule" "main3" {
  name                        = "DenyInternetInBound"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_network_security_rule" "main4" {
  name                        = "AllowVnetOutBound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_lb" "main" {
  name                = "TestLoadBalancer"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.main.id
  }
  tags = {
    project = "AzureWebServerDeploy"
  }
}

resource "azurerm_lb_rule" "main" {
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.main.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.main.id
}

resource "azurerm_lb_backend_address_pool" "main" {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.main.id
  name                = "BackEndAddressPool"
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags = {
    project = "AzureWebServerDeploy"
  }
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_availability_set" "main" {
  name                = "${var.prefix}-availability-set"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  platform_fault_domain_count = 2
  tags = {
    project = "AzureWebServerDeploy"
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  count                           = var.minimum-number-of-vm
  name                            = "${var.prefix}-vm-${count.index}"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_DS1_v2"
  admin_username                  = var.username
  admin_password                  = var.password
  disable_password_authentication = false
  availability_set_id = azurerm_availability_set.main.id
  network_interface_ids = [
    azurerm_network_interface.main[count.index].id,
  ]
  source_image_id = data.azurerm_image.search.id

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  tags = {
    project = "AzureWebServerDeploy"
  }
}

resource "azurerm_network_interface" "main" {
  count               = var.minimum-number-of-vm
  name                = "${var.prefix}-nic-${count.index}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = {
    project = "AzureWebServerDeploy"
  }
}

resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.internal.id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_network_interface_security_group_association" "main" {
  count                     = var.minimum-number-of-vm
  network_interface_id      = azurerm_network_interface.main[count.index].id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count                   = var.minimum-number-of-vm
  network_interface_id    = azurerm_network_interface.main[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}