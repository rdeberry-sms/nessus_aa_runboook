data "azurerm_automation_account" "ops" {
  name                = ""
  resource_group_name = ""
}

data "azurerm_resource_group" "ops" {
  name = ""
}

data "azurerm_resource_group" "sa" {
  name = var.sa_rg
}

data "azurerm_user_assigned_identity" "identity" {
  name                = ""
  resource_group_name = ""
}

data "azurerm_subscription" "sa" {
}

data "azurerm_storage_account" "sa" {
  name                = var.sa_acct
  resource_group_name = data.azurerm_resource_group.sa.name
}

data "azurerm_storage_container" "sa" {
  name                 = var.sa_container
  storage_account_name = data.azurerm_storage_account.sa.name
}
