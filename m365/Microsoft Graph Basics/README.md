# Microsoft Graph Basics

## Preparing Module

* Need to add the Powershell module first

```powershell
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Write-Host "Microsoft.Graph module not found. Installing now..." -ForegroundColor Yellow
    
    # Ensure NuGet package provider is present (required for PSGallery installations)
    if (-not (Get-PackageProvider -ListAvailable -Name NuGet -ErrorAction SilentlyContinue)) {
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null
    }
    
    # Install the module for the current user
    Install-Module -Name Microsoft.Graph -Scope CurrentUser -Repository PSGallery -Force
    Write-Host "Microsoft.Graph module installed successfully." -ForegroundColor Green
} else {
    Write-Host "Microsoft.Graph module is already installed." -ForegroundColor Cyan
}

# Import the module into the current session
Import-Module Microsoft.Graph
Write-Host "Microsoft.Graph module imported and ready to use!" -ForegroundColor Green
```

## Connecting to a M365 Tenant

```powershell
Connect-MgGraph -TenantId
```

## Disconnecting

```powershell
Disconnect-MgGraph -TenantId
```

## Listing users

###  Show all tenant users

```powershell
Get-MgUser -All -Select DisplayName, UserPrincipalName, Mail, AccountEnabled | Format-Table DisplayName, UserPrincipalName, Mail, AccountEnabled
```

### Show all global admins

```powershell
foreach ($member in $adminMembers) {
>>     $user = Get-MgUser -UserId $member.Id
>>     [PSCustomObject]@{
>>         DisplayName       = $user.DisplayName
>>         UserPrincipalName = $user.UserPrincipalName
>>     }
>> }
```