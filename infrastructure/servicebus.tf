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

resource "azurerm_role_assignment" "order-app" {
  scope                = azurerm_servicebus_queue.orders.id
  role_definition_name = "Azure Service Bus Data Owner"
  principal_id         = azurerm_user_assigned_identity.order-app-identity.principal_id
}

resource "kubernetes_config_map" "service-bus-config" {
  metadata {
    name      = "service-bus-config"
    namespace = kubernetes_namespace.order.metadata.0.name
  }

  data = {
    QUEUE_NAME     = "orders"
    HOST_NAME      = "${azurerm_servicebus_namespace.aks-workshop.name}.servicebus.windows.net"
  }

}