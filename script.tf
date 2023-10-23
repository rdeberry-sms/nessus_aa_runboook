resource "azurerm_storage_blob" "scripts" {
  for_each               = fileset(path.module, "scripts/*")
  name                   = trim(each.key, "scripts/")
  storage_account_name   = data.azurerm_storage_account.sa.name
  storage_container_name = data.azurerm_storage_container.sa.name
  type                   = var.sa_file_type
  source                 = each.key
}
