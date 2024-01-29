resource "kubernetes_namespace" "order" {
  metadata {
    name = "order"
  }
}

resource "azurerm_user_assigned_identity" "order-app-identity" {
  name                = "order-app-identity"
  resource_group_name = data.azurerm_resource_group.aks-workshop.name 
  location            = data.azurerm_resource_group.aks-workshop.location
}

resource "kubernetes_service_account" "order-app-sa" {
  metadata {
    name = "order-app-sa"
    namespace = kubernetes_namespace.order.metadata.0.name
    annotations = {
         "azure.workload.identity/client-id" = azurerm_user_assigned_identity.order-app-identity.client_id
    }
  }
}

resource "azurerm_federated_identity_credential" "order-app" {
  name                = "order-app"
  resource_group_name = data.azurerm_resource_group.aks-workshop.name 
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.order-app-identity.id
  subject             = "system:serviceaccount:${kubernetes_namespace.order.metadata.0.name}:${kubernetes_service_account.order-app-sa.metadata.0.name}"
}

resource "azurerm_federated_identity_credential" "keda-operator" {
  name                = "keda-operator"
  resource_group_name = data.azurerm_resource_group.aks-workshop.name 
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.order-app-identity.id
  subject             = "system:serviceaccount:kube-system:keda-operator"
}