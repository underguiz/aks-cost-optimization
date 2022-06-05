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

resource "kubernetes_namespace" "order" {
  metadata {
    name = "order"
  }
}

resource "kubernetes_config_map" "service-bus-connection-str" {
  metadata {
    name      = "service-bus-connection-str"
    namespace = kubernetes_namespace.order.metadata.0.name
  }

  data = {
    QUEUE_NAME     = "orders"
    CONNECTION_STR = azurerm_servicebus_queue_authorization_rule.consumer-app.primary_connection_string
  }

}