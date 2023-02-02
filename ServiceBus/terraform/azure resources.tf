# Creating resource group
resource "azurerm_resource_group" "servicebus-labs-resources" {
  name     = "servicebus-labs-rg"
  location = "eastus"
}

# Creating servicebus Service
# Creating servicebus namespace
resource "azurerm_servicebus_namespace" "labsServiceBusNamespace" {
  name                = "labsServiceBusNamespace"
  location            = azurerm_resource_group.servicebus-labs-resources.location
  resource_group_name = azurerm_resource_group.servicebus-labs-resources.name
  sku                 = "Standard"

  tags = {
    source = "Dev"
  }
}

# Creating queue
resource "azurerm_servicebus_queue" "labServiceBusQueue" {
  name         = "labServiceBusQueue"
  namespace_id = azurerm_servicebus_namespace.labsServiceBusNamespace.id

  enable_partitioning = true
}

# Creating topic
resource "azurerm_servicebus_topic" "labServiceBusTopic" {
  name         = "labServiceBusTopic"
  namespace_id = azurerm_servicebus_namespace.labsServiceBusNamespace.id

  enable_partitioning = true
}

# Creating topic subscription 1
resource "azurerm_servicebus_subscription" "labServiceBusTopicSub1" {
  name               = "labServiceBusTopicSub1"
  topic_id           = azurerm_servicebus_topic.labServiceBusTopic.id
  max_delivery_count = 1
  requires_session = false
}

# Creating topic subscription 2
resource "azurerm_servicebus_subscription" "labServiceBusTopicSub2" {
  name               = "labServiceBusTopicSub2"
  topic_id           = azurerm_servicebus_topic.labServiceBusTopic.id
  max_delivery_count = 1
}

# Creating storage account to be used in Functions
resource "azurerm_storage_account" "labsServiceBusStorageAccount" {
  name                     = "labsservicebussa"
  location                 = azurerm_resource_group.servicebus-labs-resources.location
  resource_group_name      = azurerm_resource_group.servicebus-labs-resources.name
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "Dev"
  }
}
  
# Creating  app service plan
resource "azurerm_service_plan" "labsServiceBusServicePlan" {
  name                = "labsservicebus-serviceplan"
  location                 = azurerm_resource_group.servicebus-labs-resources.location
  resource_group_name      = azurerm_resource_group.servicebus-labs-resources.name
  os_type             = "Windows"
  sku_name            = "S1"
}

resource "azurerm_application_insights" "labsServiceBusAppInsights" {
  name                = "labsServiceBusAppInsights"
  location                 = azurerm_resource_group.servicebus-labs-resources.location
  resource_group_name      = azurerm_resource_group.servicebus-labs-resources.name
  application_type    = "web"
}

#Creating azure function app
resource "azurerm_windows_function_app" "labsServiceBusFunctionApp" {
  name                       = "labsservicebusfunctionapp"
  location                 = azurerm_resource_group.servicebus-labs-resources.location
  resource_group_name      = azurerm_resource_group.servicebus-labs-resources.name
  storage_account_name       = azurerm_storage_account.labsServiceBusStorageAccount.name
  storage_account_access_key = data.azurerm_storage_account.thisLabsServiceBusAccount.primary_access_key
  service_plan_id            = data.azurerm_service_plan.thisAppServicePlan.id

   app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = data.azurerm_application_insights.thisAppInsights.instrumentation_key
   # FUNCTIONS_EXTENSION_VERSION = "~3"
   }

  site_config {
      application_stack {
      dotnet_version = "v4.0"
    }
  }
}