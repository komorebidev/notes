# Azure Files

* Requires global admin

## Required modules

### Prerequisites

- The hybrid user must have the appropriate **SMB permissions assigned at the Azure Resource Group containing the Storage Account**.
- Sign in to Windows using the **same hybrid identity** that will be used when running the Azure Files Hybrid join process.
- Ensure connectivity to Azure Files over **TCP port 445**.
- Download and extract the provided ZIP package (`temp.zip`) before beginning.

### Synchronize Azure AD Connect

```powershell
# Allow local script execution for the current user
Set-ExecutionPolicy `
    -ExecutionPolicy Unrestricted `
    -Scope CurrentUser

# Import Azure AD Connect module
Import-Module ADSync

# Trigger a delta synchronization
Start-ADSyncSyncCycle `
    -PolicyType Delta
```

### Install Active Directory Tools

```powershell
# Install RSAT Active Directory tools
Add-WindowsCapability `
    -Online `
    -Name "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0"

# Verify installation
Get-WindowsCapability `
    -Online `
    -Name "Rsat.ActiveDirectory.DS-LDS.Tools*"

# Load the Active Directory module
Import-Module ActiveDirectory
```

### Install Azure Storage PowerShell Modules

```powershell
# Install Az.Storage
Install-Module `
    -Name Az.Storage `
    -AllowClobber `
    -Scope CurrentUser

# Import Az.Storage
Import-Module Az.Storage

# Copy AzFilesHybrid module to PowerShell module path
.\CopyToPSPath.ps1

# Import AzFilesHybrid
Import-Module AzFilesHybrid
```

### Validate Azure Files Hybrid Configuration

```powershell
# Validate Azure Files AD DS integration
Debug-AzStorageAccountADDSAuth
```

### Test SMB Connectivity

```powershell
Test-NetConnection `
    -ComputerName "cypriotstorage.file.core.windows.net" `
    -Port 445
```

A successful result should show:

```text
TcpTestSucceeded : True
```

### Test Azure File Share Access

### Temporary Drive Mapping

```powershell
New-PSDrive `
    -Name "Z" `
    -PSProvider FileSystem `
    -Root "\\cypriotstorage.file.core.windows.net\cypriotfileshare" `
    -ErrorAction Stop
```

### Persistent Drive Mapping

```powershell
New-PSDrive `
    -Name "Z" `
    -PSProvider FileSystem `
    -Root "\\cypriotstorage.file.core.windows.net\cypriotshare" `
    -Persist
```

### Verify Loaded Modules

```powershell
Get-Module
```

### Example Output

```text
ModuleType Version    Name
---------- -------    ----
Manifest   1.0.1.0    ActiveDirectory
Binary     1.0.0.0    ADSync
Script     5.3.3      Az.Accounts
Script     11.4.0     Az.Compute
Script     7.25.1     Az.Network
Script     9.0.3      Az.Resources
Script     9.6.0      Az.Storage
Script     0.3.3.0    AzFilesHybrid
Script     0.3.2.0    AzFilesHybrid
...
```

### Purpose of AzFilesHybrid

**AzFilesHybrid** is Microsoft's PowerShell module used to integrate Azure Files with on-premises Active Directory Domain Services (AD DS).

Typical scenarios include:

- Hybrid identity authentication for Azure Files
- Domain joining Azure Storage Accounts
- NTFS ACL management
- SMB access using Active Directory credentials
- Migrating traditional file servers to Azure Files

### Troubleshooting

### Port 445 Blocked

If the connectivity test fails:

```powershell
Test-NetConnection `
    -ComputerName "cypriotstorage.file.core.windows.net" `
    -Port 445
```

Check:

- Corporate firewall rules
- ISP restrictions on SMB traffic
- Network security groups (NSGs)
- Azure Firewall policies

### Authentication Failures

Verify:

```powershell
Debug-AzStorageAccountADDSAuth
```

Common causes:

- Azure AD Connect synchronization has not completed.
- Storage account is not properly joined to AD DS.
- User lacks SMB Share permissions.
- User is not logged on using the expected hybrid identity.
- Kerberos ticket issues requiring sign-out/sign-in.

### Script Encoding

If saving any accompanying PowerShell scripts (`.ps1`), use **UTF-8 with BOM** encoding to avoid issues with module imports and non-English characters.

In VS Code:

```text
Save with Encoding
→ UTF-8 with BOM
```

## Sample script

## Prerequisites

- Ensure the user has the appropriate **Azure Files SMB permissions**.
- Verify outbound access to **TCP port 445**.
- Run PowerShell as the user who will access the Azure File Share.
- Save any PowerShell scripts as **UTF-8 with BOM**.

---

## Configure PowerShell Execution Policy

```powershell
Set-ExecutionPolicy `
    -ExecutionPolicy Unrestricted `
    -Scope CurrentUser
```

---

## Verify SMB Connectivity

```powershell
Test-NetConnection `
    -ComputerName "portquiz.net" `
    -Port 445
```

Successful output should include:

```text
TcpTestSucceeded : True
```

---

## Domain Controller Tasks

### Import Azure AD Connect Module

```powershell
Import-Module ADSync
```

### Trigger Delta Synchronization

```powershell
Start-ADSyncSyncCycle `
    -PolicyType Delta
```

---

## Domain-Joined Workstation Tasks

### Install RSAT Active Directory Tools

```powershell
Add-WindowsCapability `
    -Online `
    -Name "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0"

Get-WindowsCapability `
    -Online `
    -Name "Rsat.ActiveDirectory.DS-LDS.Tools*"
```

### Import Active Directory Module

```powershell
Import-Module ActiveDirectory
```

---

## Install Required Azure Modules

### Install Az PowerShell

```powershell
Install-Module `
    -Name Az `
    -AllowClobber `
    -Scope CurrentUser
```

### Install Microsoft Graph PowerShell SDK

```powershell
Install-Module `
    -Name Microsoft.Graph `
    -AllowClobber `
    -Scope CurrentUser
```

### Install Azure Storage Module

```powershell
Install-Module `
    -Name Az.Storage `
    -AllowClobber `
    -Scope CurrentUser
```

### Import Azure Storage Module

```powershell
Import-Module Az.Storage
```

---

## Install AzFilesHybrid

### Unblock the Helper Script

```powershell
Unblock-File .\CopyToPSPath.ps1
```

### Copy Module to PowerShell Path

```powershell
.\CopyToPSPath.ps1
```

### Import AzFilesHybrid

```powershell
Import-Module AzFilesHybrid
```

---

## Validate Azure Storage
