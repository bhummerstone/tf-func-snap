resource "azurerm_storage_account" "sa" {
  name                     = "bhfuncsnapstg"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "ZRS"
}

resource "azurerm_storage_account" "funcstg" {
  name                     = "bhfuncsnapfuncstg"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account_customer_managed_key" "cmk" {
  storage_account_id = azurerm_storage_account.sa.id
  key_vault_id       = azurerm_key_vault.kv.id
  key_name           = azurerm_key_vault_key.cmkkey.name
}

resource "azurerm_role_assignment" "func_access_stg" {
    scope = azurerm_storage_account.sa.id
    role_definition_name = "Storage Blob Data Contributor"
    principal_id = azurerm_linux_function_app.fa.identity[0].principal_id
}