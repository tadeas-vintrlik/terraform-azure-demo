data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

resource "random_id" "sa_suffix" {
  byte_length = 4
  keepers = {
    sub_id = data.azurerm_subscription.current.id
  }
}

resource "azurerm_resource_group" "tfstate" {
  name     = "rg-tfstate"
  location = "westeurope"
}

resource "azurerm_storage_account" "tfstate" {
  name                            = "tfstatesa${lower(random_id.sa_suffix.hex)}"
  resource_group_name             = azurerm_resource_group.tfstate.name
  location                        = azurerm_resource_group.tfstate.location
  account_tier                    = "Standard"
  account_replication_type        = "ZRS"
  public_network_access_enabled   = true
  allow_nested_items_to_be_public = false
  min_tls_version                 = "TLS1_2"

  blob_properties {
    versioning_enabled = true
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}

resource "azurerm_management_lock" "rg_lock" {
  name       = "rg-tfstate-lock"
  scope      = azurerm_resource_group.tfstate.id
  lock_level = "CanNotDelete"
  notes      = "This Resource Group contains the Terraform State and should not be deleted."
}
