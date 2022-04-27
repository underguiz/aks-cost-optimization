data "local_file" "start-stop-aks-ps" {
  filename = "../demos/runbook/start-stop-aks.ps1"
}

resource "azurerm_automation_account" "start-stop-aks" {
  name                = "start-stop-aks"
  resource_group_name = data.azurerm_resource_group.aks-workshop.name 
  location            = data.azurerm_resource_group.aks-workshop.location
  sku_name            = "Basic"
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_automation_runbook" "start-stop-aks" {
  name                    = "start-stop-aks"
  resource_group_name     = data.azurerm_resource_group.aks-workshop.name 
  location                = data.azurerm_resource_group.aks-workshop.location
  automation_account_name = azurerm_automation_account.start-stop-aks.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "Start Stop AKS"
  runbook_type            = "PowerShell"
  content                 = data.local_file.start-stop-aks-ps.content
}

resource "time_offset" "tomorrow" {
  offset_days = 1
}

locals {
  start_time = "8:00"
  stop_time  = "19:00"
  date       = substr(time_offset.tomorrow.rfc3339, 0, 10)
  timezone   = "America/Sao_Paulo"
}

resource "azurerm_automation_schedule" "start" {
  name                    = "start-aks"
  automation_account_name = azurerm_automation_account.start-stop-aks.name
  resource_group_name     = data.azurerm_resource_group.aks-workshop.name 
  frequency               = "Day"
  timezone                = local.timezone
  start_time              = "${local.date}T${local.start_time}:00-03:00"
  description             = "Start AKS"
}

resource "azurerm_automation_schedule" "stop" {
  name                    = "stop-aks"
  automation_account_name = azurerm_automation_account.start-stop-aks.name
  resource_group_name     = data.azurerm_resource_group.aks-workshop.name 
  frequency               = "Day"
  timezone                = local.timezone
  start_time              = "${local.date}T${local.stop_time}:00-03:00"
  description             = "Stop AKS"
}

resource "azurerm_automation_job_schedule" "start-aks" {
  resource_group_name     = data.azurerm_resource_group.aks-workshop.name 
  automation_account_name = azurerm_automation_account.start-stop-aks.name
  runbook_name            = azurerm_automation_runbook.start-stop-aks.name
  schedule_name           = azurerm_automation_schedule.start.name

  parameters = {
    clustername   = azurerm_kubernetes_cluster.aks-dev.name
    resourcegroup = azurerm_kubernetes_cluster.aks-dev.resource_group_name
    action        = "start"
  }

}

resource "azurerm_automation_job_schedule" "stop-aks" {
  resource_group_name     = data.azurerm_resource_group.aks-workshop.name 
  automation_account_name = azurerm_automation_account.start-stop-aks.name
  runbook_name            = azurerm_automation_runbook.start-stop-aks.name
  schedule_name           = azurerm_automation_schedule.stop.name
  
  parameters = {
    clustername   = azurerm_kubernetes_cluster.aks-dev.name
    resourcegroup = azurerm_kubernetes_cluster.aks-dev.resource_group_name
    action        = "stop"
  }

}
