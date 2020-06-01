provider "azurerm" {
  version = "=2.11.0"
  features {}
}

resource "azurerm_kubernetes_cluster" "main" {
  count = var.create_cluster ? 1 : 0

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix

  private_cluster_enabled = var.private_cluster_enabled

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_D2_v2"
    vnet_subnet_id = var.subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    outbound_type  = var.outbound_type

  }
}