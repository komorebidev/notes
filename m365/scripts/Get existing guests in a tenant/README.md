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