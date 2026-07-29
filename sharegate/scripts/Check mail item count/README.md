# Checking mail item count

* Sharegate reports can be hard to read
* Just in case, this reporting command can be used
* But Sharegate support says that relying on item counts is not reliable
* And that their reporting is the most accurate

## Script

```powershell
# Install the Exchange Online PowerShell module
Install-Module `
    -Name ExchangeOnlineManagement `
    -Scope CurrentUser `
    -Force

# Connect to the source tenant
Connect-ExchangeOnline `
    -UserPrincipalName "migr_adm@starasiaenterprises.onmicrosoft.com"

# Connect to the destination tenant
Connect-ExchangeOnline `
    -UserPrincipalName "migr_adm@polarishd.onmicrosoft.com"

# Source mailbox folder statistics
Get-MailboxFolderStatistics `
    -Identity "s.takakura@polaris-holdings.com" |
    Select-Object Name, ItemsInFolder |
    Sort-Object ItemsInFolder -Descending |
    Format-Table -AutoSize

# Destination mailbox folder statistics
Get-MailboxFolderStatistics `
    -Identity "takakura.shigeru@p-hd.com" |
    Select-Object Name, ItemsInFolder |
    Sort-Object ItemsInFolder -Descending |
    Format-Table -AutoSize

# Source mailbox statistics
Get-MailboxStatistics `
    -Identity "s.takakura@polaris-holdings.com" |
    Select-Object DisplayName, ItemCount, DeletedItemCount

# Destination mailbox statistics
Get-MailboxStatistics `
    -Identity "takakura.shigeru@p-hd.com" |
    Select-Object DisplayName, ItemCount, DeletedItemCount
```