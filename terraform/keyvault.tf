resource "azurerm_key_vault" "kv" {
  name                        = "bhfuncsnapakv"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = "72f988bf-86f1-41af-91ab-2d7cd011db47"
  sku_name                    = "standard"

  #   access_policy {
  #     tenant_id = "72f988bf-86f1-41af-91ab-2d7cd011db47"
  #     object_id = "ec5f94a8-41f3-416c-8736-ed8a8b4093c7"

  #     key_permissions = [
  #       "create",
  #       "get",
  #       "delete",
  #       "list",
  #       "wrapKey",
  #       "unwrapKey",
  #       "get",
  #     ]

  #     secret_permissions = [
  #       "set",
  #       "get",
  #       "delete",
  #       "purge",
  #       "recover",
  #     ]
  #   }
}

resource "azurerm_key_vault_access_policy" "function_access_policy" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = azurerm_linux_function_app.fa.identity[0].principal_id
  key_permissions     = ["Get"]  
  secret_permissions  = ["Get"]  
}

resource "azurerm_key_vault_access_policy" "ben_access_policy" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.client_id
  key_permissions = [
    "Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import",
    "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update",
    "Verify", "WrapKey"
  ]

  secret_permissions = [
    "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
  ]

  certificate_permissions = [
    "Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers",
    "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers",
    "Purge", "Recover", "Restore", "SetIssuers", "Update"
  ]

  storage_permissions = [
    "Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS",
    "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update"
  ]
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
