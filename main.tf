# resource group
resource "azurerm_resource_group" "lab001" {
  name     = var.resource_group_name
  location = var.location
}

# Storage account
resource "azurerm_storage_account" "notsecure" {
  name                     = "aisecuritylab001" 
  resource_group_name      = azurerm_resource_group.lab001.name
  location                 = azurerm_resource_group.lab001.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  public_network_access_enabled = true
}



# # virtual network within the resource group
# resource "azurerm_virtual_network" "example" {
#   name                = "example-network"
#   resource_group_name = azurerm_resource_group.example.name
#   location            = azurerm_resource_group.example.location
#   address_space       = ["10.0.0.0/16"]
# }