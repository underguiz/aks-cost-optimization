resource "random_string" "servicebus" {
  length           = 6
  special          = false
}

resource "azurerm_servicebus_namespace" "aks-workshop" {
  name                = "aks-workshop-${random_string.servicebus.result}"
  resource_group_name = data.azurerm_resource_group.aks-workshop.name 
  location            = data.azurerm_resource_group.aks-workshop.location
  sku                 = "Standard"
}

resource "azurerm_servicebus_queue" "orders" {
  name         = "orders"
  namespace_id = azurerm_servicebus_namespace.aks-workshop.id
}

resource "azurerm_servicebus_queue_authorization_rule" "consumer-app" {
  name     = "consumerapp"
  queue_id = azurerm_servicebus_queue.orders.id

  listen = true
  send   = true
  manage = true
}