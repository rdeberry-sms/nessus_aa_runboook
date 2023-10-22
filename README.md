## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.77.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_automation_job_schedule.nessus_install](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_job_schedule) | resource |
| [azurerm_automation_runbook.nessus_install](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_runbook) | resource |
| [azurerm_automation_schedule.nessus_install](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_schedule) | resource |
| [azurerm_storage_blob.scripts](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob) | resource |
| [azurerm_automation_account.ops](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/automation_account) | data source |
| [azurerm_resource_group.ops](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_resource_group.sa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_storage_account.sa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account) | data source |
| [azurerm_storage_container.sa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_container) | data source |
| [azurerm_subscription.sa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |
| [azurerm_user_assigned_identity.identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/user_assigned_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_expiry_time"></a> [expiry\_time](#input\_expiry\_time) | When to start the runbook schedule | `string` | `"2027-10-07T06:00:15+02:00"` | no |
| <a name="input_nessus_schedule"></a> [nessus\_schedule](#input\_nessus\_schedule) | Name of the Schedule in Automation Account | `string` | `"nessus-automation-schedule"` | no |
| <a name="input_runbook_description"></a> [runbook\_description](#input\_runbook\_description) | Description of the Runbook | `string` | `"This runbook will Download and Install the Nessus Agent"` | no |
| <a name="input_runbook_name"></a> [runbook\_name](#input\_runbook\_name) | Name of the runbook | `string` | `"nessus_agent_install"` | no |
| <a name="input_runbook_type"></a> [runbook\_type](#input\_runbook\_type) | Name of the language used | `string` | `"PowerShell"` | no |
| <a name="input_sa_acct"></a> [sa\_acct](#input\_sa\_acct) | Name of the Storage Account | `string` | n/a | yes |
| <a name="input_sa_container"></a> [sa\_container](#input\_sa\_container) | Name of the Storage Account Container | `string` | n/a | yes |
| <a name="input_sa_file_type"></a> [sa\_file\_type](#input\_sa\_file\_type) | Type of file in Storage Account | `string` | `"Block"` | no |
| <a name="input_sa_rg"></a> [sa\_rg](#input\_sa\_rg) | Name of the Storage Account Resource Group | `string` | n/a | yes |
| <a name="input_sa_sub"></a> [sa\_sub](#input\_sa\_sub) | Subscription ID where the Storage Account lives | `string` | n/a | yes |
| <a name="input_schedule_description"></a> [schedule\_description](#input\_schedule\_description) | Schedule Description | `string` | `"This is schedule to download and install Nessus"` | no |
| <a name="input_schedule_frequency"></a> [schedule\_frequency](#input\_schedule\_frequency) | Job frequency | `string` | `"Week"` | no |
| <a name="input_scritpname_linux"></a> [scritpname\_linux](#input\_scritpname\_linux) | Something | `string` | `"nessus-linux.sh"` | no |
| <a name="input_scritpname_win"></a> [scritpname\_win](#input\_scritpname\_win) | Something | `string` | `"nessus-windows.ps1"` | no |
| <a name="input_start_time"></a> [start\_time](#input\_start\_time) | When to start the runbook schedule | `string` | `"2024-10-07T06:00:15+02:00"` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Azure AD Tenate ID of the Azure subscription | `string` | n/a | yes |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | Name of the Timezone | `string` | `"America/New_York"` | no |
| <a name="input_week_days"></a> [week\_days](#input\_week\_days) | Schedule Description | `list(string)` | <pre>[<br>  "Monday",<br>  "Wednesday",<br>  "Saturday"<br>]</pre> | no |

## Outputs

No outputs.
