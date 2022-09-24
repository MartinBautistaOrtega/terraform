terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.22.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "3377ed40-88ae-4fe3-869b-3941d6f7b78c"
}