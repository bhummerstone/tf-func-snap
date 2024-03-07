terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      verson = "~3"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "func-snap"
  location = "uksouth"
}
