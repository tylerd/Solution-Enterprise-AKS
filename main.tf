provider "azurerm" {
  version = "=2.11.0"
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "rg-solution-enterprise-aks"
  location = "West US 2"
  tags = {
    GitHub = "https://github.com/tylerd/Solution-Enterprise-AKS"
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-solution-enterprise-aks"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  address_space = ["10.100.0.0/16"]
}

resource "azurerm_subnet" "default" {
  name                 = "default"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name

  address_prefixes = ["10.100.0.0/24"]
}

resource "azurerm_subnet" "aks_blue" {
  name                 = "subnet-aks-blue"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name

  address_prefixes = ["10.100.1.0/25"]

  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_subnet" "aks_green" {
  name                 = "subnet-aks-green"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.main.name

  address_prefixes = ["10.100.1.128/25"]

}

module "aks_blue" {
  source = "./aks_cluster"

  resource_group_name     = azurerm_resource_group.main.name
  name                    = "aks-solution-enterprise-aks"
  location                = azurerm_resource_group.main.location
  dns_prefix              = "tyleraks2"
  subnet_id               = azurerm_subnet.aks_blue.id
  private_cluster_enabled = true
}

module "aks_green" {
  source = "./aks_cluster"

  create_cluster = false

  resource_group_name     = azurerm_resource_group.main.name
  name                    = "aks-solution-enterprise-aks-green"
  location                = azurerm_resource_group.main.location
  dns_prefix              = "tyleraks-green"
  subnet_id               = azurerm_subnet.aks_green.id
  private_cluster_enabled = false
}
