resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-workshop"
  dns_prefix          = "aks-workshop"
  resource_group_name = data.azurerm_resource_group.aks-workshop.name 
  location            = data.azurerm_resource_group.aks-workshop.location

  role_based_access_control_enabled = true
  oidc_issuer_enabled               = true
  workload_identity_enabled         = true
  
  workload_autoscaler_profile {
    keda_enabled = true
  }

  default_node_pool {
    name                        = "regular"
    vm_size                     = "Standard_D4as_v4"
    enable_auto_scaling         = true
    max_count                   = 8
    min_count                   = 1
    vnet_subnet_id              = azurerm_subnet.app.id
    zones                       = [ 1, 2, 3 ]
  }

  network_profile {
    network_plugin      = "azure"
    service_cidr        = "172.29.100.0/24"
    dns_service_ip      = "172.29.100.10"
    network_plugin_mode = "overlay"
  }

  identity {
    type = "SystemAssigned"
  }

}

resource "azurerm_kubernetes_cluster_node_pool" "spot" {
  name                  = "spot"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_D4as_v4"
  priority              = "Spot"
  eviction_policy       = "Delete"
  node_taints           = [ "kubernetes.azure.com/scalesetpriority=spot:NoSchedule" ]
  vnet_subnet_id        = azurerm_subnet.app.id
  max_count             = 8
  min_count             = 2
  enable_auto_scaling   = true
  zones                 = [ 1, 2, 3 ]
}

resource "azurerm_role_assignment" "aks-subnet" {
  scope                = azurerm_virtual_network.aks-workshop.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.aks.identity.0.principal_id
}

resource "azurerm_kubernetes_cluster" "aks-dev" {
  name                = "aks-workshop-dev"
  dns_prefix          = "aks-workshop-dev"
  resource_group_name = data.azurerm_resource_group.aks-workshop.name 
  location            = data.azurerm_resource_group.aks-workshop.location

  role_based_access_control_enabled = true
  azure_policy_enabled              = true

  default_node_pool {
    name                = "regular"
    vm_size             = "Standard_D4as_v4"
    node_count          = 1
    vnet_subnet_id      = azurerm_subnet.app.id
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    service_cidr        = "172.29.100.0/24"
    dns_service_ip      = "172.29.100.10"
  }

  identity {
    type = "SystemAssigned"
  }

}

resource "azurerm_role_assignment" "aks-automation" {
  scope                = azurerm_kubernetes_cluster.aks-dev.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_automation_account.start-stop-aks.identity.0.principal_id
}