# Azure CLI Basics

## Installing Az module

```powershell
if (-not (Get-Module -ListAvailable -Name Az)) {
    Write-Host "Az module not found. Installing now..." -ForegroundColor Yellow
    
    # Ensure NuGet package provider is available
    if (-not (Get-PackageProvider -ListAvailable -Name NuGet -ErrorAction SilentlyContinue)) {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null
    }
    
    # Install the Az module for the current user
    Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
    Write-Host "Az module installed successfully." -ForegroundColor Green
} else {
    Write-Host "Az module is already installed." -ForegroundColor Cyan
}

# Import the module into the session
Import-Module Az
Write-Host "Az module imported and ready to use!" -ForegroundColor Green
```

## Login and Account Management Commands
* Basic Interactive Login
* Opens your default browser to sign in interactively:

```powershell
az login
```

* Login with a Specific Tenant
* Specify the target tenant ID or domain if you belong to multiple organizations:

```powershell
az login --tenant
```

* Login via Device Code
* Useful for remote servers, SSH terminals, or environments without a local web browser:

```powershell
az login --use-device-code
```

* Login with a Service Principal
* Authenticate non-interactively using an app registration for scripts and automation:

```powershell
az login --service-principal -u  -p  --tenant
```

* Managing Subscriptions After Login
* List all accessible subscriptions:

```powershell
az account list --output table
```

* Change your active subscription:

```powershell
az account set --subscription ""
```

* View your currently active subscription:

```powershell
az account show
```

* Log out (clear local credentials):

```powershell
az logout
```
