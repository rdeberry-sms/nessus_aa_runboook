resource "azurerm_automation_runbook" "nessus_install" {
  name                    = var.runbook_name
  location                = data.azurerm_resource_group.ops.location
  resource_group_name     = data.azurerm_automation_account.ops.resource_group_name
  automation_account_name = data.azurerm_automation_account.ops.name
  log_verbose             = true
  log_progress            = true
  description             = var.runbook_description
  runbook_type            = var.runbook_type
  tags                    = var.default_tags
  content = templatefile("${path.module}/runbook/nessus.ps1", {
    umi                         = data.azurerm_user_assigned_identity.identity.client_id
    tenantid                    = var.tenant_id
    scriptnamelinux             = var.scritpname_linux
    scriptnamewindows           = var.scritpname_win
    storageaccountcontainer     = data.azurerm_storage_container.sa.name
    storageaccountresourcegroup = data.azurerm_resource_group.sa.name
    storageaccountname          = var.sa_acct
    workbookname                = var.runbook_name
    storageaccountsub           = data.azurerm_subscription.sa.subscription_id
    client_id                   = data.azurerm_user_assigned_identity.identity.client_id
    vms_to_exclude              = join(",", [for vm in local.vms_file_content : "\"${vm}\""])
    defaultsub                  = ""
  })
}

resource "azurerm_automation_job_schedule" "nessus_install" {
  resource_group_name     = data.azurerm_automation_account.ops.resource_group_name
  automation_account_name = data.azurerm_automation_account.ops.name
  schedule_name           = azurerm_automation_schedule.nessus_install.name
  runbook_name            = azurerm_automation_runbook.nessus_install.name

}

resource "azurerm_automation_schedule" "nessus_install" {
  name                    = var.nessus_schedule
  resource_group_name     = data.azurerm_automation_account.ops.resource_group_name
  automation_account_name = data.azurerm_automation_account.ops.name
  frequency               = var.schedule_frequency
  timezone                = var.timezone
  start_time              = var.start_time
  description             = var.schedule_description
  week_days               = var.week_days
  expiry_time             = var.expiry_time
}
