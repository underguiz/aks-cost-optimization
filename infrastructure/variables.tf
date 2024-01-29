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

output "managed_identity_id" {
  value       = azurerm_user_assigned_identity.order-app-identity.client_id
  description = "Managed Identity Client ID"
}