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

resource "azurerm_key_vault_access_policy" "my_access_policy" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = azurerm_function_app.fa.identity[0].principal_id
  key_permissions     = ["get"]  # Adjust permissions as needed
  secret_permissions  = ["get"]  # Adjust permissions as needed
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
