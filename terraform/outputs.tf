# Resource Group Outputs
output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.sql_rg.name
}

output "resource_group_location" {
  description = "Location of the created resource group"
  value       = azurerm_resource_group.sql_rg.location
}

# SQL Server Outputs
output "sql_server_name" {
  description = "Name of the SQL Server"
  value       = azurerm_mssql_server.sql_server.name
}

output "sql_server_id" {
  description = "ID of the SQL Server"
  value       = azurerm_mssql_server.sql_server.id
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL Server"
  value       = azurerm_mssql_server.sql_server.fully_qualified_domain_name
}

output "sql_server_admin_username" {
  description = "Administrator username for the SQL Server"
  value       = azurerm_mssql_server.sql_server.administrator_login
  sensitive   = true
}

output "sql_server_identity_principal_id" {
  description = "Principal ID of the SQL Server managed identity"
  value       = azurerm_mssql_server.sql_server.identity[0].principal_id
}

# SQL Database Outputs
output "sql_database_name" {
  description = "Name of the SQL Database"
  value       = azurerm_mssql_database.sql_database.name
}

output "sql_database_id" {
  description = "ID of the SQL Database"
  value       = azurerm_mssql_database.sql_database.id
}

output "sql_database_collation" {
  description = "Collation of the SQL Database"
  value       = azurerm_mssql_database.sql_database.collation
}

output "sql_database_max_size_gb" {
  description = "Maximum size of the SQL Database in GB"
  value       = azurerm_mssql_database.sql_database.max_size_gb
}

output "sql_database_sku_name" {
  description = "SKU name of the SQL Database"
  value       = azurerm_mssql_database.sql_database.sku_name
}

# Key Vault Outputs
output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.sql_kv.name
}

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.sql_kv.id
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.sql_kv.vault_uri
}

# Connection String (for reference - use Key Vault secret in production)
output "sql_connection_string" {
  description = "SQL Server connection string template (use Key Vault secret for password)"
  value       = "Server=${azurerm_mssql_server.sql_server.fully_qualified_domain_name};Database=${azurerm_mssql_database.sql_database.name};User Id=${azurerm_mssql_server.sql_server.administrator_login};Password=<use-key-vault-secret>;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  sensitive   = true
}

# Firewall Rules
output "firewall_rules" {
  description = "List of configured firewall rules"
  value = {
    azure_services = var.allow_azure_services ? [{
      name      = "AllowAzureServices"
      start_ip  = "0.0.0.0"
      end_ip    = "0.0.0.0"
    }] : []
    custom_rules = [for rule_name, rule in var.firewall_rules : {
      name     = rule_name
      start_ip = rule.start_ip
      end_ip   = rule.end_ip
    }]
  }
}

# Security Information
output "security_features" {
  description = "Security features enabled"
  value = {
    threat_detection_enabled     = true
    auditing_enabled            = var.enable_auditing
    security_alert_policy       = var.enable_security_alert_policy
    azure_ad_authentication     = var.azuread_admin_login != null ? true : false
    tls_version                 = azurerm_mssql_server.sql_server.minimum_tls_version
    managed_identity_enabled    = true
  }
}

# Backup Configuration
output "backup_configuration" {
  description = "Backup and retention configuration"
  value = {
    short_term_retention_days = var.backup_retention_days
    weekly_retention         = var.weekly_retention
    monthly_retention        = var.monthly_retention
    yearly_retention         = var.yearly_retention
    week_of_year            = var.week_of_year
  }
}
