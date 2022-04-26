resource "azurerm_resource_policy_assignment" "aks-dev-resource-limit" {
  name                 = "AKS Dev Resource Limit"
  resource_id          = azurerm_kubernetes_cluster.aks-dev.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e345eecc-fa47-480f-9e88-67dcc122b164"
  parameters = <<PARAMS
    {
      "cpuLimit": {
        "value": "1000m"
      },
      "memoryLimit": {
        "value": "1Gi"
      }
    }
PARAMS
}