resource "random_string" "kv_name" {
  length = 13
  lower = true
  numeric = false
  special = false
  upper = false
}

resource "azurerm_key_vault" "kv" {
  name                        = "bhfskv-${random_string.kv_name.result}"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  enable_rbac_authorization = true
  soft_delete_retention_days = 7
  purge_protection_enabled = true

}

resource "azurerm_role_assignment" "func_access_kv" {
    scope = azurerm_key_vault.kv.id
    role_definition_name = "Key Vault Secrets User"
    principal_id = azurerm_linux_function_app.fa.identity[0].principal_id
}

resource "azurerm_role_assignment" "des_access_kv" {
    scope = azurerm_key_vault.kv.id
    role_definition_name = "Key Vault Secrets User"
    principal_id = azurerm_disk_encryption_set.des.identity[0].principal_id
}

resource "azurerm_role_assignment" "des_access_kv_crypto" {
    scope = azurerm_key_vault.kv.id
    role_definition_name = "Key Vault Crypto Service Encryption User"
    principal_id = azurerm_disk_encryption_set.des.identity[0].principal_id
}

resource "azurerm_role_assignment" "user_access_kv" {
   scope = azurerm_key_vault.kv.id
   role_definition_name = "Key Vault Administrator"
   principal_id = "ec5f94a8-41f3-416c-8736-ed8a8b4093c7" #data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "stg_access_kv" {
   scope = azurerm_key_vault.kv.id
   role_definition_name = "Key Vault Crypto Service Encryption User"
   #principal_id = azurerm_storage_account.sa.identity.0.principal_id
   principal_id = data.azurerm_storage_account.sa_wrapper.identity.0.principal_id
}

resource "azurerm_key_vault_key" "cmkkey" {
  name         = "bhfuncsnapcmk"

  depends_on = [ azurerm_role_assignment.user_access_kv ]

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

  depends_on = [ azurerm_role_assignment.user_access_kv ]

  key_vault_id = azurerm_key_vault.kv.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "unwrapKey",
    "wrapKey",
  ]
}
