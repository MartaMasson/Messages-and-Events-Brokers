data "azurerm_service_plan" "thisAppServicePlan" {
  name                     = azurerm_service_plan.labsEventHubServicePlan.name
  resource_group_name      = azurerm_resource_group.eventhub-labs-resources.name
}

data "azurerm_storage_account" "thisLabsEventHubStorageAccount" {
  name                     = azurerm_storage_account.labsEventHubStorageAccount.name
  resource_group_name      = azurerm_resource_group.eventhub-labs-resources.name
}

data "azurerm_application_insights" "thisAppInsights" {
  name                = azurerm_application_insights.labsEventHubAppInsights.name
  resource_group_name = azurerm_resource_group.eventhub-labs-resources.name
}