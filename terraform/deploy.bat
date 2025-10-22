@echo off
REM Azure SQL Database Terraform Deployment Script for Windows
REM This script helps with the deployment process on Windows

setlocal enabledelayedexpansion

REM Function to print status
:print_status
echo [INFO] %~1
goto :eof

:print_success
echo [SUCCESS] %~1
goto :eof

:print_warning
echo [WARNING] %~1
goto :eof

:print_error
echo [ERROR] %~1
goto :eof

REM Check prerequisites
:check_prerequisites
call :print_status "Checking prerequisites..."

REM Check if Terraform is installed
terraform version >nul 2>&1
if errorlevel 1 (
    call :print_error "Terraform is not installed. Please install Terraform >= 1.0"
    exit /b 1
)

REM Check if Azure CLI is installed
az version >nul 2>&1
if errorlevel 1 (
    call :print_error "Azure CLI is not installed. Please install Azure CLI"
    exit /b 1
)

REM Check Azure CLI login status
az account show >nul 2>&1
if errorlevel 1 (
    call :print_error "Not logged into Azure CLI. Please run 'az login'"
    exit /b 1
)

call :print_success "Prerequisites check completed"
goto :eof

REM Validate terraform files
:validate_terraform
call :print_status "Validating Terraform configuration..."

terraform validate
if errorlevel 1 (
    call :print_error "Terraform validation failed"
    exit /b 1
)

call :print_success "Terraform validation completed"
goto :eof

REM Check if tfvars file exists
:check_tfvars
if not exist "terraform.tfvars" (
    call :print_warning "terraform.tfvars file not found"
    call :print_status "Creating terraform.tfvars from example..."
    
    if exist "terraform.tfvars.example" (
        copy "terraform.tfvars.example" "terraform.tfvars" >nul
        call :print_warning "Please edit terraform.tfvars with your specific values before proceeding"
        call :print_status "Required variables to configure:"
        echo   - sql_server_name (must be globally unique)
        echo   - sql_database_name
        echo   - key_vault_name (must be globally unique)
        echo   - azuread_admin_login and azuread_admin_object_id (recommended)
        echo   - firewall_rules (configure based on your network)
        pause
    ) else (
        call :print_error "terraform.tfvars.example not found"
        exit /b 1
    )
)
goto :eof

REM Initialize Terraform
:init_terraform
call :print_status "Initializing Terraform..."

terraform init
if errorlevel 1 (
    call :print_error "Terraform initialization failed"
    exit /b 1
)

call :print_success "Terraform initialization completed"
goto :eof

REM Plan deployment
:plan_deployment
call :print_status "Creating Terraform plan..."

terraform plan -out=tfplan
if errorlevel 1 (
    call :print_error "Terraform plan failed"
    exit /b 1
)

call :print_success "Terraform plan created"
call :print_warning "Please review the plan above before applying"
goto :eof

REM Apply deployment
:apply_deployment
call :print_status "Applying Terraform configuration..."

if exist "tfplan" (
    terraform apply tfplan
) else (
    terraform apply
)

if errorlevel 1 (
    call :print_error "Terraform apply failed"
    exit /b 1
)

call :print_success "Terraform apply completed"
goto :eof

REM Display outputs
:show_outputs
call :print_status "Displaying Terraform outputs..."

terraform output

call :print_success "Deployment completed successfully!"
call :print_status "Important next steps:"
echo   1. Retrieve SQL admin password from Key Vault
echo   2. Test database connectivity
echo   3. Configure application connection strings
echo   4. Review security settings and firewall rules
echo   5. Set up monitoring and alerting
goto :eof

REM Retrieve admin password
:get_admin_password
call :print_status "Retrieving SQL admin password from Key Vault..."

for /f "tokens=*" %%i in ('terraform output -raw key_vault_name 2^>nul') do set KEY_VAULT_NAME=%%i

if defined KEY_VAULT_NAME (
    for /f "tokens=*" %%i in ('az keyvault secret show --vault-name "!KEY_VAULT_NAME!" --name "sql-admin-password" --query value -o tsv 2^>nul') do set PASSWORD=%%i
    
    if defined PASSWORD (
        call :print_success "SQL Admin password retrieved successfully"
        call :print_warning "Password (handle with care): !PASSWORD!"
    ) else (
        call :print_error "Failed to retrieve password from Key Vault"
    )
) else (
    call :print_error "Could not determine Key Vault name"
)
goto :eof

REM Clean up
:clean_up
call :print_status "Cleaning up temporary files..."

if exist "tfplan" (
    del tfplan
    call :print_status "Removed terraform plan file"
)
goto :eof

REM Main deployment function
:deploy
call :print_status "Starting Azure SQL Database deployment..."

call :check_prerequisites
if errorlevel 1 exit /b 1

call :check_tfvars
if errorlevel 1 exit /b 1

call :init_terraform
if errorlevel 1 exit /b 1

call :validate_terraform
if errorlevel 1 exit /b 1

call :plan_deployment
if errorlevel 1 exit /b 1

set /p "CONFIRM=Do you want to apply this plan? (y/N): "
if /i "!CONFIRM!"=="y" (
    call :apply_deployment
    if errorlevel 1 exit /b 1
    
    call :show_outputs
    
    set /p "GET_PASSWORD=Do you want to retrieve the SQL admin password? (y/N): "
    if /i "!GET_PASSWORD!"=="y" (
        call :get_admin_password
    )
    
    call :clean_up
) else (
    call :print_status "Deployment cancelled"
    call :clean_up
)
goto :eof

REM Destroy infrastructure
:destroy
call :print_warning "This will destroy all resources created by this Terraform configuration"
set /p "CONFIRM=Are you sure you want to destroy the infrastructure? (y/N): "

if /i "!CONFIRM!"=="y" (
    call :print_status "Destroying infrastructure..."
    terraform destroy
    if errorlevel 1 (
        call :print_error "Terraform destroy failed"
        exit /b 1
    )
    call :print_success "Infrastructure destroyed"
) else (
    call :print_status "Destroy cancelled"
)
goto :eof

REM Main script logic
if "%1"=="deploy" (
    call :deploy
) else if "%1"=="plan" (
    call :check_prerequisites
    call :check_tfvars
    call :init_terraform
    call :validate_terraform
    call :plan_deployment
) else if "%1"=="apply" (
    call :check_prerequisites
    call :apply_deployment
    call :show_outputs
) else if "%1"=="destroy" (
    call :check_prerequisites
    call :destroy
) else if "%1"=="password" (
    call :get_admin_password
) else if "%1"=="validate" (
    call :check_prerequisites
    call :validate_terraform
) else if "%1"=="clean" (
    call :clean_up
) else (
    echo Usage: %0 {deploy^|plan^|apply^|destroy^|password^|validate^|clean}
    echo.
    echo Commands:
    echo   deploy    - Full deployment process (recommended)
    echo   plan      - Create and show terraform plan
    echo   apply     - Apply terraform configuration
    echo   destroy   - Destroy all infrastructure
    echo   password  - Retrieve SQL admin password from Key Vault
    echo   validate  - Validate terraform configuration
    echo   clean     - Clean up temporary files
    echo.
    echo Example: %0 deploy
    exit /b 1
)

endlocal
