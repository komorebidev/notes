# Azure CLI Basics

## Installing Azure CLI

* For basic connection to Azure tenant

```powershell
$azInstalled = $null -ne (Get-Command az -ErrorAction SilentlyContinue)

if (-not $azInstalled) {
    Write-Host "Azure CLI not found. Installing via winget..." -ForegroundColor Yellow
    
    # Install Azure CLI using winget
    winget install --exact --id Microsoft.AzureCLI -e --accept-source-agreements --accept-package-agreements
    
    # Detect current PowerShell version to reopen the correct shell
    $psMajorVersion = $PSVersionTable.PSVersion.Major
    if ($psMajorVersion -ge 7) {
        $psExe = "pwsh.exe"
    } else {
        $psExe = "powershell.exe"
    }

    Write-Host "Restarting PowerShell session ($psExe) to pick up the new PATH variables..." -ForegroundColor Cyan
    
    # Launch a new window of the corresponding PowerShell version and exit this one
    Start-Process $psExe
    exit
} else {
    Write-Host "Azure CLI is already installed and ready to use." -ForegroundColor Green
}
```

## Installing Az module

* For read and write of Azure resources

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
