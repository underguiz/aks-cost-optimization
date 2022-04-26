variable "workshop_rg" {
  type    = string
  default = "aks-workshop"
}

output "acr" {
  value       = azurerm_container_registry.acr.name
  description = "Azure Container Registry Name"
}

output "servicebus_namespace" {
  value       = azurerm_servicebus_namespace.aks-workshop.name
  description = "Service Bus Namespace"
}

output "servicebus_connection_string" {
  value       = nonsensitive(azurerm_servicebus_queue_authorization_rule.consumer-app.primary_connection_string)
  description = "Service Bus Connection String"
}

