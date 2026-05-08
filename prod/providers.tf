terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    # These values are provided via -backend-config in deploy.sh
    # resource_group_name  = ""
    # storage_account_name = ""
    # container_name       = ""
    key              = "prod.tfstate"
    use_azuread_auth = true
  }
}

provider "azurerm" {
  features {}
}
