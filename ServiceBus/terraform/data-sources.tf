data "azurerm_service_plan" "thisAppServicePlan" {
  name                     = azurerm_service_plan.labsServiceBusServicePlan.name
  resource_group_name      = azurerm_resource_group.servicebus-labs-resources.name
}

data "azurerm_storage_account" "thisLabsServiceBusAccount" {
  name                     = azurerm_storage_account.labsServiceBusStorageAccount.name
  resource_group_name      = azurerm_resource_group.servicebus-labs-resources.name
}

data "azurerm_application_insights" "thisAppInsights" {
  name                = azurerm_application_insights.labsServiceBusAppInsights.name
  resource_group_name      = azurerm_resource_group.servicebus-labs-resources.name
}