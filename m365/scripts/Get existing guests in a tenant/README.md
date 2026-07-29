# Get existing guests in a tenant

* In migrations, sometimes the guest accounts in a tenant must be migrated manually

* Use this script to export the guests from the source tenant

## Script

```powershell
# Connect to Microsoft Graph
Connect-MgGraph `
    -Scopes "Reports.Read.All", "User.Read.All", "Sites.Read.All"

# Export all guest users to CSV
Get-MgUser -Filter "UserType eq 'Guest'" |
    Select-Object `
        Id,
        DisplayName,
        Mail,
        UserPrincipalName,
        UserType |
    Export-Csv `
        -Path ".\GuestUsers.csv" `
        -NoTypeInformation `
        -Encoding UTF8
```

# One Code Block

```powershell
# =============================================================================
# Azure Files Hybrid Validation and SMB Access
# =============================================================================
#
# Prerequisites
#
# - Ensure SMB permissions are assigned at the Azure Resource Group
#   containing the Storage Account for the hybrid user.
#
# - Sign in to Windows as the same hybrid user that will be used when
#   running the Azure Files Hybrid join process.
#
# - Extract the provided ZIP package (temp.zip) before proceeding.
#
# - Save PowerShell scripts as UTF-8 with BOM.
#
# =============================================================================
# Configure PowerShell
# =============================================================================

Set-ExecutionPolicy `
    -ExecutionPolicy Unrestricted `
    -Scope CurrentUser

# =============================================================================
# Trigger Azure AD Connect Sync
# =============================================================================

Import-Module ADSync

Start-ADSyncSyncCycle `
    -PolicyType Delta

# =============================================================================
# Install Active Directory Administration Tools
# =============================================================================

Add-WindowsCapability `
    -Online `
    -Name "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0"

Get-WindowsCapability `
    -Online `
    -Name "Rsat.ActiveDirectory.DS-LDS.Tools*"

Import-Module ActiveDirectory

# =============================================================================
# Install Azure Storage Modules
# =============================================================================

Install-Module `
    -Name Az.Storage `
    -AllowClobber `
    -Scope CurrentUser

Import-Module Az.Storage

# =============================================================================
# Install AzFilesHybrid
# =============================================================================

.\CopyToPSPath.ps1

Import-Module AzFilesHybrid

# =============================================================================
# Validate Azure Files AD Authentication
# =============================================================================

Debug-AzStorageAccountADDSAuth

# =============================================================================
# Test SMB Connectivity
# =============================================================================

Test-NetConnection `
    -ComputerName "cypriotstorage.file.core.windows.net" `
    -Port 445

# =============================================================================
# Test Azure File Share Access
# =============================================================================

# Temporary mapping

New-PSDrive `
    -Name "Z" `
    -PSProvider FileSystem `
    -Root "\\cypriotstorage.file.core.windows.net\cypriotfileshare" `
    -ErrorAction Stop

# Persistent mapping

New-PSDrive `
    -Name "Z" `
    -PSProvider FileSystem `
    -Root "\\cypriotstorage.file.core.windows.net\cypriotshare" `
    -Persist

# =============================================================================
# Verify Installed Modules
# =============================================================================

Get-Module

# Expected modules include:
#
# ActiveDirectory
# ADSync
# Az.Accounts
# Az.Compute
# Az.Network
# Az.Resources
# Az.Storage
# AzFilesHybrid
# Microsoft.Graph.*
# SmbShare
#
# Example output:
#
# ModuleType Version    Name
# ---------- -------    ----
# Manifest   1.0.1.0    ActiveDirectory
# Binary     1.0.0.0    ADSync
# Script     5.3.3      Az.Accounts
# Script     11.4.0     Az.Compute
# Script     7.25.1     Az.Network
# Script     9.0.3      Az.Resources
# Script     9.6.0      Az.Storage
# Script     0.3.3.0    AzFilesHybrid
# Script     2.9.1      Microsoft.Graph.Authentication
# Script     2.9.1      Microsoft.Graph.Users
# Manifest   2.0.0.0    SmbShare

# =============================================================================
# Troubleshooting
# =============================================================================
#
# If Debug-AzStorageAccountADDSAuth fails:
#
# - Verify the user has SMB Share permissions.
# - Verify Azure AD Connect synchronization completed successfully.
# - Verify the Storage Account is joined to Active Directory.
# - Verify the user is logged in using the intended hybrid identity.
#
# If Test-NetConnection fails:
#
# - Verify TCP port 445 is not blocked by:
#     * Corporate firewall
#     * ISP restrictions
#     * Network Security Groups (NSGs)
#     * Azure Firewall policies
#
# Successful output should contain:
#
# TcpTestSucceeded : True
#
# =============================================================================
# Script Encoding
# =============================================================================
#
# Save all .ps1 files as:
#
# UTF-8 with BOM
#
# VS Code:
#
# Save with Encoding
# -> UTF-8 with BOM
#
# =============================================================================
```