# Azure SQL Database Terraform Configuration

This Terraform configuration creates a comprehensive Azure SQL Database setup with security best practices, backup policies, and monitoring capabilities.

## Features

### Core Components
- **Azure SQL Server** with administrator credentials
- **Azure SQL Database** with configurable SKU and size
- **Azure Key Vault** for secure credential storage
- **Resource Group** for organizing resources

### Security Features
- Managed Identity for SQL Server
- Azure AD Administrator integration
- TLS 1.2 minimum encryption
- Threat Detection with email alerts
- Firewall rules configuration
- VNet integration support
- Auditing capabilities
- Security Alert Policy

### Backup & Recovery
- Configurable short-term retention (1-35 days)
- Long-term retention policies (weekly, monthly, yearly)
- Point-in-time restore capabilities

### Monitoring & Compliance
- Extended auditing policy
- Security alert notifications
- Threat detection monitoring
- Comprehensive output values for integration

## Prerequisites

1. **Azure CLI** installed and authenticated
2. **Terraform** >= 1.0 installed
3. **Azure subscription** with appropriate permissions
4. **Storage Account** (optional, for auditing and security alerts)

## Quick Start

### 1. Clone and Navigate
```bash
git checkout story/19034-SQL-DB-Instance
cd terraform
```

### 2. Configure Variables
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your specific values
```

### 3. Initialize Terraform
```bash
terraform init
```

### 4. Plan Deployment
```bash
terraform plan
```

### 5. Deploy Infrastructure
```bash
terraform apply
```

## Configuration

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `sql_server_name` | Unique name for SQL Server | `sql-server-prod-001` |
| `sql_database_name` | Name for the SQL Database | `myapp-database` |
| `key_vault_name` | Unique name for Key Vault | `kv-sql-secrets-001` |

### Important Configuration Options

#### Database SKU Options
```hcl
# Basic tier
database_sku = "Basic"

# Standard tier (recommended for production)
database_sku = "S1"  # 20 DTUs
database_sku = "S2"  # 50 DTUs
database_sku = "S3"  # 100 DTUs

# Premium tier (high performance)
database_sku = "P1"  # 125 DTUs
database_sku = "P2"  # 250 DTUs
```

#### Firewall Rules
```hcl
firewall_rules = {
  "office-network" = {
    start_ip = "203.0.113.0"
    end_ip   = "203.0.113.255"
  }
  "application-servers" = {
    start_ip = "10.0.1.100"
    end_ip   = "10.0.1.110"
  }
}
```

#### Azure AD Integration
```hcl
azuread_admin_login     = "admin@yourcompany.com"
azuread_admin_object_id = "12345678-1234-1234-1234-123456789012"
```

## Security Best Practices

### 1. Credential Management
- SQL admin password is auto-generated and stored in Key Vault
- Use Azure AD authentication when possible
- Enable managed identity for applications

### 2. Network Security
- Configure minimal firewall rules
- Use VNet integration for internal applications
- Disable public access if not required

### 3. Monitoring
- Enable auditing for compliance requirements
- Configure threat detection alerts
- Set up security alert notifications

### 4. Backup Strategy
```hcl
# Short-term retention
backup_retention_days = 14

# Long-term retention
weekly_retention  = "P4W"   # 4 weeks
monthly_retention = "P12M"  # 12 months
yearly_retention  = "P5Y"   # 5 years
```

## Outputs

After successful deployment, Terraform provides these key outputs:

- `sql_server_fqdn` - Connection endpoint
- `sql_database_name` - Database name
- `key_vault_uri` - Key Vault URI for secret retrieval
- `sql_connection_string` - Template connection string

## Post-Deployment Steps

### 1. Retrieve Admin Password
```bash
# Using Azure CLI
az keyvault secret show --vault-name "your-key-vault-name" --name "sql-admin-password" --query value -o tsv
```

### 2. Test Connectivity
```bash
# Using sqlcmd (if installed)
sqlcmd -S your-server-name.database.windows.net -d your-database-name -U sqladmin -P
```

### 3. Configure Application Connection
Use the managed identity or create dedicated database users for applications.

## Maintenance

### Updating the Configuration
1. Modify `terraform.tfvars`
2. Run `terraform plan` to review changes
3. Run `terraform apply` to apply changes

### Backup Verification
- Monitor backup completion in Azure Portal
- Test restore procedures regularly
- Verify long-term retention policies

### Security Monitoring
- Review threat detection alerts
- Monitor audit logs
- Update firewall rules as needed

## Troubleshooting

### Common Issues

1. **Name conflicts**: SQL Server names must be globally unique
2. **Permissions**: Ensure sufficient Azure permissions
3. **Firewall**: Verify IP ranges for connectivity
4. **Key Vault access**: Check access policies for secret retrieval

### Terraform State
- Store state remotely for team collaboration
- Use state locking to prevent conflicts
- Regular state backups recommended

## Cost Optimization

1. **Right-size SKU**: Start with smaller SKUs and scale up
2. **Backup retention**: Balance compliance needs with storage costs
3. **Zone redundancy**: Enable only if high availability is required
4. **Elastic pools**: Consider for multiple databases

## Compliance

This configuration supports common compliance requirements:
- **GDPR**: Auditing and data protection features
- **SOX**: Access logging and audit trails
- **HIPAA**: Encryption and access controls
- **PCI DSS**: Network security and monitoring

## Support

For issues with this Terraform configuration:
1. Review Terraform logs: `terraform apply -debug`
2. Check Azure Activity Log for deployment issues
3. Verify Azure permissions and quotas
4. Consult Azure SQL Database documentation

## Version History

- **v1.0**: Initial SQL Database deployment configuration
- Features: Basic database, security, backup, monitoring
- Terraform version: >= 1.0
- AzureRM provider: ~> 3.0
