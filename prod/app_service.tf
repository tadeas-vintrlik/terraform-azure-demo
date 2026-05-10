resource "azurerm_service_plan" "asp" {
  name                = "asp-prod-demo"
  resrouce_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resrouce_group.rg.location
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "web_app" {
  name                = "webapp-prod-demo-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {
    always_on = false # Just for the demo
  }
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}
