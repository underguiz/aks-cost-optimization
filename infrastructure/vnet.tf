resource "azurerm_virtual_network" "aks-workshop" {
  name                = "aks-workshop"
  resource_group_name = data.azurerm_resource_group.aks-workshop.name 
  location            = data.azurerm_resource_group.aks-workshop.location
  address_space       = ["10.254.0.0/16"]
}

resource "azurerm_subnet" "app" {
  name                 = "app"
  resource_group_name  = data.azurerm_resource_group.aks-workshop.name 
  virtual_network_name = azurerm_virtual_network.aks-workshop.name
  address_prefixes     = ["10.254.0.0/24"]
}