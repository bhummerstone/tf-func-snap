resource "azurerm_key_vault" "kv" {
  name                        = "bhfuncsnapakv"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
}

resource "azurerm_role_assignment" "func_access_kv" {
    scope = azurerm_key_vault.kv.id
    role_definition_name = "Key Vault Secrets User"
    principal_id = azurerm_linux_function_app.fa.identity[0].principal_id
}

resource "azurerm_role_assignment" "ben_access_kv" {
    scope = azurerm_key_vault.kv.id
    role_definition_name = "Key Vault Administrator"
    principal_id = data.azurerm_client_config.current.client_id
}

resource "azurerm_key_vault_key" "cmkkey" {
  name         = "bhfuncsnapcmk"
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "unwrapKey",
    "wrapKey",
  ]
}

resource "azurerm_key_vault_key" "vmkey" {
  name         = "bhfuncsnapvmkey"
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "unwrapKey",
    "wrapKey",
  ]
}
