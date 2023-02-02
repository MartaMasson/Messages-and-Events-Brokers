output "resource_group_id" {
  value = azurerm_resource_group.eventhub-labs-resources.id
}

output "azurerm_eventhub_namespace_id"  {
  value = azurerm_eventhub_namespace.labsEventHubNamespace.id
}

output "azurerm_eventhub_namespace_default_primary_connection_string" {
  description = "Event Hub namespace default primary connection string"
  value       = azurerm_eventhub_namespace.labsEventHubNamespace.default_primary_connection_string
  sensitive = true
}

output "lab1EventHub_id"  {
  value = azurerm_eventhub.lab1EventHub.id
}

