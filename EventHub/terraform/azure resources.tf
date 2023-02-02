# Creating resource group
resource "azurerm_resource_group" "eventhub-labs-resources" {
  name     = "eventhub-labs-rg"
  location = "eastus"
}

# Creating eventhub Service
# Creating eventhub namespace
resource "azurerm_eventhub_namespace" "labsEventHubNamespace" {
  name                = "labsEventHubNamespace"
  location            = azurerm_resource_group.eventhub-labs-resources.location
  resource_group_name = azurerm_resource_group.eventhub-labs-resources.name
  sku                 = "Standard"
  capacity            = 1

  tags = {
    environment = "Dev"
  }
}

# Creating eventhub 
resource "azurerm_eventhub" "lab1EventHub" {
  name                = "lab1EventHub"
  namespace_name      = azurerm_eventhub_namespace.labsEventHubNamespace.name
  resource_group_name = azurerm_resource_group.eventhub-labs-resources.name
  partition_count     = 2
  message_retention   = 1
}

# Creating consumer groups for eventhub 
resource "azurerm_eventhub_consumer_group" "group1" {
  name                = "lab1EventHubGroup1"
  namespace_name      = azurerm_eventhub_namespace.labsEventHubNamespace.name
  eventhub_name       = azurerm_eventhub.lab1EventHub.name
  resource_group_name = azurerm_resource_group.eventhub-labs-resources.name
}

resource "azurerm_eventhub_consumer_group" "group2" {
  name                = "lab1EventHubGroup2"
  namespace_name      = azurerm_eventhub_namespace.labsEventHubNamespace.name
  eventhub_name       = azurerm_eventhub.lab1EventHub.name
  resource_group_name = azurerm_resource_group.eventhub-labs-resources.name
}

# Creating storage account to be used in EventHub e Functions
resource "azurerm_storage_account" "labsEventHubStorageAccount" {
  name                     = "labseventhubsa"
  resource_group_name      = azurerm_resource_group.eventhub-labs-resources.name
  location                 = azurerm_resource_group.eventhub-labs-resources.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "Dev"
  }
}
resource "azurerm_storage_container" "labsEventHubSAContainer" {
  name                  = "labseventhubsacontainer"
  storage_account_name  = azurerm_storage_account.labsEventHubStorageAccount.name
  container_access_type = "blob"
  }
  
# Creating  app service plan
resource "azurerm_service_plan" "labsEventHubServicePlan" {
  name                = "labseventhub-serviceplan"
  resource_group_name      = azurerm_resource_group.eventhub-labs-resources.name
  location                 = azurerm_resource_group.eventhub-labs-resources.location
  os_type             = "Windows"
  sku_name            = "S1"
}

resource "azurerm_application_insights" "labsEventHubAppInsights" {
  name                = "labsEventHubAppInsights"
  resource_group_name = azurerm_resource_group.eventhub-labs-resources.name
  location            = azurerm_resource_group.eventhub-labs-resources.location
  application_type    = "web"
}

#Creating azure function app
resource "azurerm_windows_function_app" "labsEventHubFunctionApp" {
  name                       = "labseventhubfunctionapp"
  resource_group_name        = azurerm_resource_group.eventhub-labs-resources.name
  location                   = azurerm_resource_group.eventhub-labs-resources.location
  storage_account_name       = azurerm_storage_account.labsEventHubStorageAccount.name
  storage_account_access_key = data.azurerm_storage_account.thisLabsEventHubStorageAccount.primary_access_key
  service_plan_id            = data.azurerm_service_plan.thisAppServicePlan.id

   app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = data.azurerm_application_insights.thisAppInsights.instrumentation_key
   # FUNCTIONS_EXTENSION_VERSION = "~3"
   }

  site_config {
      application_stack {
      dotnet_version = "4.0"
    }
  }
}