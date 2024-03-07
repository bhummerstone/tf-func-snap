resource "azurerm_app_service_plan" "asp" {
  name                = "bhfuncsnapasp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "fa" {
  name                       = "bhfuncsnapfa"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  app_service_plan_id        = azurerm_app_service_plan.asp.id
  storage_account_name       = azurerm_storage_account.funcstg.name
  storage_account_access_key = azurerm_storage_account.funcstg.primary_access_key

  site_config {
    linux_fx_version = "PYTHON|3.10"
  }

  identity {
    type = "SystemAssigned"
  }
}