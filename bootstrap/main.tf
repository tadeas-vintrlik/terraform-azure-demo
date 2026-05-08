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
  name                          = "tfstatesa${lower(random_id.sa_suffix.hex)}"
  resource_group_name           = azurerm_resource_group.tfstate.name
  location                      = azurerm_resource_group.tfstate.location
  account_tier                  = "Standard"
  account_replication_type      = "ZRS"
  public_network_access_enabled = true
  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
    ip_rules       = var.current_ip != "" ? [var.current_ip] : []
  }
  min_tls_version = "TLS1_2"

  blob_properties {
    versioning_enabled = true
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}

# Setup the current user as Storage Blob Data Contributor
resource "azurerm_role_assignment" "tfstate_data_contributor" {
  scope                = azurerm_storage_account.tfstate.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}
