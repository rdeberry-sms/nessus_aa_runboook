
variable "default_tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
  }
}

variable "tenant_id" {
  description = "Azure AD Tenate ID of the Azure subscription"
  type        = string
}

variable "nessus_schedule" {
  description = "Name of the Schedule in Automation Account"
  type        = string
  default     = "nessus-automation-schedule"
}

variable "timezone" {
  description = "Name of the Timezone"
  type        = string
  default     = "America/New_York"
}

variable "schedule_description" {
  description = "Schedule Description"
  type        = string
  default     = "This is schedule to download and install Nessus"
}

variable "week_days" {
  description = "Schedule Description"
  type        = list(string)
  default     = ["Monday", "Wednesday", "Saturday"]
}

variable "scritpname_linux" {
  default     = "nessus-linux.sh"
  description = "Something"
  type        = string
}

variable "scritpname_win" {
  default     = "nessus-windows.ps1"
  description = "Something"
  type        = string
}

variable "sa_container" {
  description = "Name of the Storage Account Container"
  type        = string
}

variable "sa_rg" {
  description = "Name of the Storage Account Resource Group"
  type        = string
}

variable "sa_sub" {
  description = "Subscription ID where the Storage Account lives"
  type        = string
}

variable "sa_acct" {
  description = "Name of the Storage Account"
  type        = string
}


locals {
  vms_file_content = split("\n", file("${path.module}/vms.txt"))
}

variable "schedule_frequency" {
  description = "Job frequency"
  type        = string
  default     = "Week"
}

variable "runbook_name" {
  description = "Name of the runbook"
  type        = string
  default     = "nessus_agent_install"
}

variable "runbook_type" {
  description = "Name of the language used"
  type        = string
  default     = "PowerShell"
}

variable "runbook_description" {
  description = "Description of the Runbook"
  type        = string
  default     = "This runbook will Download and Install the Nessus Agent"
}

variable "start_time" {
  description = "When to start the runbook schedule"
  type        = string
  default     = "2024-10-07T06:00:15+02:00"
}

variable "expiry_time" {
  description = "When to start the runbook schedule"
  type        = string
  default     = "2027-10-07T06:00:15+02:00"
}

variable "sa_file_type" {
  default     = "Block"
  description = "Type of file in Storage Account"
  type        = string
}
