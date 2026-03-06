# Resource group
resource "azurerm_resource_group" "lab001" {
  name     = var.resource_group_name
  location = var.location
}

# Storage account
resource "azurerm_storage_account" "secure" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.lab001.name
  location                 = azurerm_resource_group.lab001.location
  account_tier             = "Standard"
  account_replication_type = "ZRS" # Zone Redundant Storage for higher availability

  # Security settings
  https_traffic_only_enabled    = true  # Enforce HTTPS for secure transfer
  public_network_access_enabled = false # Disable public network access

  # Optional advanced settings
  min_tls_version = "1.2" # Enforce minimum TLS version for compliance
}

# Virtual network within the resource group
resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  resource_group_name = azurerm_resource_group.lab001.name
  location            = azurerm_resource_group.lab001.location
  address_space       = ["10.0.0.0/16"]
}

# Subnet for storage account
resource "azurerm_subnet" "storage_subnet" {
  name                 = "storage-subnet"
  resource_group_name  = azurerm_resource_group.lab001.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes      = ["10.0.1.0/24"]
}

# Private endpoint for storage account
resource "azurerm_private_endpoint" "storage_private_endpoint" {
  name                = "storage-private-endpoint"
  resource_group_name = azurerm_resource_group.lab001.name
  location            = azurerm_resource_group.lab001.location
  subnet_id           = azurerm_subnet.storage_subnet.id

  private_service_connection {
    name                           = "storage-private-connection"
    private_connection_resource_id = azurerm_storage_account.secure.id
    is_manual_connection           = false
  }
}