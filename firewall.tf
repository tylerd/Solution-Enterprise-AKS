resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.100.2.0/24"]
}

resource "azurerm_public_ip" "firewall" {
  name                = "pip-solution-enterprise-aks-firewall"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "firewall" {
  name                = "fw-solution-enterprise-aks-firewall"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }
}

resource "azurerm_firewall_network_rule_collection" "aks_network_rule" {
  name                = "aks_network"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = azurerm_resource_group.main.name
  priority            = 100
  action              = "Allow"

  rule {
    name = "aks_api_tcp"

    source_addresses = [
      local.aks_address_prefix
    ]

    destination_addresses = [
      "*"
    ]

    destination_ports = [
      "9000",
      "22"
    ]

    protocols = [
      "TCP"
    ]
  }

  rule {
    name = "aks_api_udp"

    source_addresses = [
      local.aks_address_prefix
    ]

    destination_addresses = [
      "*"
    ]

    destination_ports = [
      "1194"
    ]

    protocols = [
      "UDP"
    ]
  }

  rule {
    name = "ubuntu_ntp"

    source_addresses = [
      local.aks_address_prefix
    ]

    destination_addresses = [
      "*"
    ]

    destination_ports = [
      "123"
    ]

    protocols = [
      "UDP"
    ]
  }

  rule {
    name = "dns"

    source_addresses = [
      local.aks_address_prefix
    ]

    destination_addresses = [
      "*"
    ]

    destination_ports = [
      "53"
    ]

    protocols = [
      "UDP"
    ]
  }
}

resource "azurerm_firewall_application_rule_collection" "aks_global_https" {
  name                = "aks_global"
  azure_firewall_name = azurerm_firewall.firewall.name
  resource_group_name = azurerm_resource_group.main.name
  priority            = 200
  action              = "Allow"

  rule {
    name = "AKS_Global_Required"

    source_addresses = [
      local.aks_address_prefix
    ]

    target_fqdns = [
      "aksrepos.azurecr.io",
      "mcr.microsoft.com",
      "*.cdn.mscr.io",
      "*.data.mcr.microsoft.com",
      "management.azure.com",
      "login.microsoftonline.com",
      "packages.microsoft.com",
      "acs-mirror.azureedge.net"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }

  rule {
    name = "AKS_API_Required"

    source_addresses = [
      local.aks_address_prefix
    ]

    target_fqdns = [
      "*.hcp.${azurerm_resource_group.main.location}.azmk8s.io",
      "*.tun.${azurerm_resource_group.main.location}.azmk8s.io"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
}
