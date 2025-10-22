#!/bin/bash

# Azure SQL Database Terraform Deployment Script
# This script helps with the deployment process

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if Terraform is installed
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install Terraform >= 1.0"
        exit 1
    fi
    
    # Check Terraform version
    TERRAFORM_VERSION=$(terraform version -json | jq -r '.terraform_version')
    print_status "Terraform version: $TERRAFORM_VERSION"
    
    # Check if Azure CLI is installed
    if ! command -v az &> /dev/null; then
        print_error "Azure CLI is not installed. Please install Azure CLI"
        exit 1
    fi
    
    # Check Azure CLI login status
    if ! az account show &> /dev/null; then
        print_error "Not logged into Azure CLI. Please run 'az login'"
        exit 1
    fi
    
    SUBSCRIPTION_NAME=$(az account show --query name -o tsv)
    print_status "Current Azure subscription: $SUBSCRIPTION_NAME"
    
    print_success "Prerequisites check completed"
}

# Function to validate terraform files
validate_terraform() {
    print_status "Validating Terraform configuration..."
    
    if ! terraform validate; then
        print_error "Terraform validation failed"
        exit 1
    fi
    
    print_success "Terraform validation completed"
}

# Function to check if tfvars file exists
check_tfvars() {
    if [ ! -f "terraform.tfvars" ]; then
        print_warning "terraform.tfvars file not found"
        print_status "Creating terraform.tfvars from example..."
        
        if [ -f "terraform.tfvars.example" ]; then
            cp terraform.tfvars.example terraform.tfvars
            print_warning "Please edit terraform.tfvars with your specific values before proceeding"
            print_status "Required variables to configure:"
            echo "  - sql_server_name (must be globally unique)"
            echo "  - sql_database_name"
            echo "  - key_vault_name (must be globally unique)"
            echo "  - azuread_admin_login and azuread_admin_object_id (recommended)"
            echo "  - firewall_rules (configure based on your network)"
            read -p "Press Enter after editing terraform.tfvars to continue..."
        else
            print_error "terraform.tfvars.example not found"
            exit 1
        fi
    fi
}

# Function to initialize Terraform
init_terraform() {
    print_status "Initializing Terraform..."
    
    terraform init
    
    print_success "Terraform initialization completed"
}

# Function to plan deployment
plan_deployment() {
    print_status "Creating Terraform plan..."
    
    terraform plan -out=tfplan
    
    print_success "Terraform plan created"
    print_warning "Please review the plan above before applying"
}

# Function to apply deployment
apply_deployment() {
    print_status "Applying Terraform configuration..."
    
    if [ -f "tfplan" ]; then
        terraform apply tfplan
    else
        terraform apply
    fi
    
    print_success "Terraform apply completed"
}

# Function to display outputs
show_outputs() {
    print_status "Displaying Terraform outputs..."
    
    terraform output
    
    print_success "Deployment completed successfully!"
    print_status "Important next steps:"
    echo "  1. Retrieve SQL admin password from Key Vault"
    echo "  2. Test database connectivity"
    echo "  3. Configure application connection strings"
    echo "  4. Review security settings and firewall rules"
    echo "  5. Set up monitoring and alerting"
}

# Function to retrieve admin password
get_admin_password() {
    print_status "Retrieving SQL admin password from Key Vault..."
    
    KEY_VAULT_NAME=$(terraform output -raw key_vault_name 2>/dev/null)
    
    if [ -n "$KEY_VAULT_NAME" ]; then
        PASSWORD=$(az keyvault secret show --vault-name "$KEY_VAULT_NAME" --name "sql-admin-password" --query value -o tsv 2>/dev/null)
        
        if [ -n "$PASSWORD" ]; then
            print_success "SQL Admin password retrieved successfully"
            print_warning "Password (handle with care): $PASSWORD"
        else
            print_error "Failed to retrieve password from Key Vault"
        fi
    else
        print_error "Could not determine Key Vault name"
    fi
}

# Function to clean up
clean_up() {
    print_status "Cleaning up temporary files..."
    
    if [ -f "tfplan" ]; then
        rm tfplan
        print_status "Removed terraform plan file"
    fi
}

# Main deployment function
deploy() {
    print_status "Starting Azure SQL Database deployment..."
    
    check_prerequisites
    check_tfvars
    init_terraform
    validate_terraform
    plan_deployment
    
    read -p "Do you want to apply this plan? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        apply_deployment
        show_outputs
        
        read -p "Do you want to retrieve the SQL admin password? (y/N): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            get_admin_password
        fi
        
        clean_up
    else
        print_status "Deployment cancelled"
        clean_up
    fi
}

# Function to destroy infrastructure
destroy() {
    print_warning "This will destroy all resources created by this Terraform configuration"
    read -p "Are you sure you want to destroy the infrastructure? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Destroying infrastructure..."
        terraform destroy
        print_success "Infrastructure destroyed"
    else
        print_status "Destroy cancelled"
    fi
}

# Parse command line arguments
case "$1" in
    "deploy")
        deploy
        ;;
    "plan")
        check_prerequisites
        check_tfvars
        init_terraform
        validate_terraform
        plan_deployment
        ;;
    "apply")
        check_prerequisites
        apply_deployment
        show_outputs
        ;;
    "destroy")
        check_prerequisites
        destroy
        ;;
    "password")
        get_admin_password
        ;;
    "validate")
        check_prerequisites
        validate_terraform
        ;;
    "clean")
        clean_up
        ;;
    *)
        echo "Usage: $0 {deploy|plan|apply|destroy|password|validate|clean}"
        echo ""
        echo "Commands:"
        echo "  deploy    - Full deployment process (recommended)"
        echo "  plan      - Create and show terraform plan"
        echo "  apply     - Apply terraform configuration"
        echo "  destroy   - Destroy all infrastructure"
        echo "  password  - Retrieve SQL admin password from Key Vault"
        echo "  validate  - Validate terraform configuration"
        echo "  clean     - Clean up temporary files"
        echo ""
        echo "Example: $0 deploy"
        exit 1
        ;;
esac
