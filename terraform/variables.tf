# Resource Group Variables
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-sql-database"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

# SQL Server Variables
variable "sql_server_name" {
  description = "Name of the SQL Server"
  type        = string
}

variable "sql_server_version" {
  description = "Version of the SQL Server"
  type        = string
  default     = "12.0"
}

variable "sql_admin_username" {
  description = "Administrator username for SQL Server"
  type        = string
  default     = "sqladmin"
}

variable "azuread_admin_login" {
  description = "Azure AD administrator login name"
  type        = string
  default     = null
}

variable "azuread_admin_object_id" {
  description = "Azure AD administrator object ID"
  type        = string
  default     = null
}

# SQL Database Variables
variable "sql_database_name" {
  description = "Name of the SQL Database"
  type        = string
}

variable "database_collation" {
  description = "Collation of the SQL Database"
  type        = string
  default     = "SQL_Latin1_General_CP1_CI_AS"
}

variable "license_type" {
  description = "License type for the database"
  type        = string
  default     = "LicenseIncluded"
  validation {
    condition     = contains(["LicenseIncluded", "BasePrice"], var.license_type)
    error_message = "License type must be either LicenseIncluded or BasePrice."
  }
}

variable "max_size_gb" {
  description = "Maximum size of the database in GB"
  type        = number
  default     = 10
}

variable "database_sku" {
  description = "SKU for the SQL Database"
  type        = string
  default     = "S0"
}

variable "zone_redundant" {
  description = "Whether the database is zone redundant"
  type        = bool
  default     = false
}

# Key Vault Variables
variable "key_vault_name" {
  description = "Name of the Key Vault"
  type        = string
}

# Firewall Rules
variable "allow_azure_services" {
  description = "Allow Azure services to access the SQL Server"
  type        = bool
  default     = true
}

variable "firewall_rules" {
  description = "Map of firewall rules"
  type = map(object({
    start_ip = string
    end_ip   = string
  }))
  default = {}
}

variable "subnet_ids" {
  description = "List of subnet IDs for VNet integration"
  type        = list(string)
  default     = []
}

# Backup and Retention Variables
variable "backup_retention_days" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 35
    error_message = "Backup retention days must be between 1 and 35."
  }
}

variable "weekly_retention" {
  description = "Weekly backup retention (ISO 8601 format)"
  type        = string
  default     = "P1W"
}

variable "monthly_retention" {
  description = "Monthly backup retention (ISO 8601 format)"
  type        = string
  default     = "P1M"
}

variable "yearly_retention" {
  description = "Yearly backup retention (ISO 8601 format)"
  type        = string
  default     = "P1Y"
}

variable "week_of_year" {
  description = "Week of year for yearly backup"
  type        = number
  default     = 1
}

# Threat Detection Variables
variable "threat_detection_email_addresses" {
  description = "List of email addresses for threat detection alerts"
  type        = list(string)
  default     = []
}

variable "threat_detection_retention_days" {
  description = "Threat detection retention period in days"
  type        = number
  default     = 0
}

variable "threat_detection_storage_account_key" {
  description = "Storage account access key for threat detection"
  type        = string
  default     = null
  sensitive   = true
}

variable "threat_detection_storage_endpoint" {
  description = "Storage endpoint for threat detection"
  type        = string
  default     = null
}

# Auditing Variables
variable "enable_auditing" {
  description = "Enable SQL Server auditing"
  type        = bool
  default     = false
}

variable "auditing_storage_endpoint" {
  description = "Storage endpoint for auditing"
  type        = string
  default     = null
}

variable "auditing_storage_account_key" {
  description = "Storage account access key for auditing"
  type        = string
  default     = null
  sensitive   = true
}

variable "auditing_retention_days" {
  description = "Auditing retention period in days"
  type        = number
  default     = 90
}

# Security Alert Policy Variables
variable "enable_security_alert_policy" {
  description = "Enable security alert policy"
  type        = bool
  default     = false
}

variable "security_alert_storage_endpoint" {
  description = "Storage endpoint for security alerts"
  type        = string
  default     = null
}

variable "security_alert_storage_account_key" {
  description = "Storage account access key for security alerts"
  type        = string
  default     = null
  sensitive   = true
}

variable "security_alert_email_addresses" {
  description = "List of email addresses for security alerts"
  type        = list(string)
  default     = []
}

variable "security_alert_retention_days" {
  description = "Security alert retention period in days"
  type        = number
  default     = 90
}

variable "disabled_alerts" {
  description = "List of disabled alert types"
  type        = list(string)
  default     = []
}

# Common Variables
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "Development"
    Project     = "SQL Database Deployment"
    ManagedBy   = "Terraform"
  }
}
