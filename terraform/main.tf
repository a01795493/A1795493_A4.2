# Configure the Azure Provider
terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.1"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Create a resource group
resource "azurerm_resource_group" "sql_rg" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

# Generate random password for SQL Server admin
resource "random_password" "sql_admin_password" {
  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric = true
}

# Create Key Vault for storing secrets
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "sql_kv" {
  name                        = var.key_vault_name
  location                    = azurerm_resource_group.sql_rg.location
  resource_group_name         = azurerm_resource_group.sql_rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
      "Set",
      "Delete",
      "Purge",
      "Recover"
    ]

    storage_permissions = [
      "Get",
    ]
  }

  tags = var.tags
}

# Store SQL Server admin password in Key Vault
resource "azurerm_key_vault_secret" "sql_admin_password" {
  name         = "sql-admin-password"
  value        = random_password.sql_admin_password.result
  key_vault_id = azurerm_key_vault.sql_kv.id

  depends_on = [azurerm_key_vault.sql_kv]
}

# Create SQL Server
resource "azurerm_mssql_server" "sql_server" {
  name                         = var.sql_server_name
  resource_group_name          = azurerm_resource_group.sql_rg.name
  location                     = azurerm_resource_group.sql_rg.location
  version                      = var.sql_server_version
  administrator_login          = var.sql_admin_username
  administrator_login_password = random_password.sql_admin_password.result
  minimum_tls_version          = "1.2"

  azuread_administrator {
    login_username = var.azuread_admin_login
    object_id      = var.azuread_admin_object_id
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Create SQL Database
resource "azurerm_mssql_database" "sql_database" {
  name           = var.sql_database_name
  server_id      = azurerm_mssql_server.sql_server.id
  collation      = var.database_collation
  license_type   = var.license_type
  max_size_gb    = var.max_size_gb
  sku_name       = var.database_sku
  zone_redundant = var.zone_redundant

  # Enable threat detection
  threat_detection_policy {
    state                      = "Enabled"
    email_account_admins       = "Enabled"
    email_addresses            = var.threat_detection_email_addresses
    retention_days             = var.threat_detection_retention_days
    storage_account_access_key = var.threat_detection_storage_account_key
    storage_endpoint           = var.threat_detection_storage_endpoint
  }

  # Configure short term retention policy
  short_term_retention_policy {
    retention_days = var.backup_retention_days
  }

  # Configure long term retention policy
  long_term_retention_policy {
    weekly_retention  = var.weekly_retention
    monthly_retention = var.monthly_retention
    yearly_retention  = var.yearly_retention
    week_of_year      = var.week_of_year
  }

  tags = var.tags
}

# Configure firewall rules
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  count            = var.allow_azure_services ? 1 : 0
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_mssql_firewall_rule" "custom_rules" {
  for_each         = var.firewall_rules
  name             = each.key
  server_id        = azurerm_mssql_server.sql_server.id
  start_ip_address = each.value.start_ip
  end_ip_address   = each.value.end_ip
}

# Configure virtual network rule (if VNet integration is required)
resource "azurerm_mssql_virtual_network_rule" "sql_vnet_rule" {
  count     = length(var.subnet_ids)
  name      = "sql-vnet-rule-${count.index}"
  server_id = azurerm_mssql_server.sql_server.id
  subnet_id = var.subnet_ids[count.index]
}

# Configure auditing
resource "azurerm_mssql_server_extended_auditing_policy" "sql_auditing" {
  count                                   = var.enable_auditing ? 1 : 0
  server_id                               = azurerm_mssql_server.sql_server.id
  storage_endpoint                        = var.auditing_storage_endpoint
  storage_account_access_key              = var.auditing_storage_account_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = var.auditing_retention_days
  log_monitoring_enabled                  = true
}

# Configure security alert policy
resource "azurerm_mssql_server_security_alert_policy" "sql_security_alert" {
  count                      = var.enable_security_alert_policy ? 1 : 0
  resource_group_name        = azurerm_resource_group.sql_rg.name
  server_name                = azurerm_mssql_server.sql_server.name
  state                      = "Enabled"
  storage_endpoint           = var.security_alert_storage_endpoint
  storage_account_access_key = var.security_alert_storage_account_key
  email_account_admins       = true
  email_addresses            = var.security_alert_email_addresses
  retention_days             = var.security_alert_retention_days

  disabled_alerts = var.disabled_alerts
}
