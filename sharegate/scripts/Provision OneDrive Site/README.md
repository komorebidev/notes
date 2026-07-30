# Provision OneDrive Site

* Sometimes user accounts on destination tenant do not have a site associated
* This means they cannot be selected as a migration target from Sharegate GUI
* To fix this, just pre-provision for the whole tenant
* Any accounts with an existing site get skipped

## Getting OneDrive Site URL

```powershell
Connect-MgGraph
(Get-MgOrganization).VerifiedDomains

# Copy the value for the .onmicrosoft as the URL for the next script

```

* Make sure to not forget https://

## Script

```powershell
# Ensure SharePoint Online Management Shell module is installed
if (-not (Get-Module -ListAvailable -Name Microsoft.Online.SharePoint.PowerShell)) {
    Write-Host "Installing Microsoft.Online.SharePoint.PowerShell..."
    Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Scope CurrentUser -Force
}
Import-Module Microsoft.Online.SharePoint.PowerShell

# Ensure Microsoft Graph module is installed
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Users)) {
    Write-Host "Installing Microsoft.Graph..."
    Install-Module -Name Microsoft.Graph -Scope CurrentUser -Force
}
Import-Module Microsoft.Graph.Users

# Prompt for the SharePoint Online Admin Center URL
$SPOAdminUrl = Read-Host "Enter your SharePoint Online Admin URL (e.g. https://contoso-admin.sharepoint.com)"

# Connect to SharePoint Online
Connect-SPOService -Url $SPOAdminUrl

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.Read.All","Directory.Read.All"

# Get all licensed member users
$users = Get-MgUser -All -Property UserPrincipalName,AssignedLicenses,UserType |
    Where-Object {
        $_.UserType -eq "Member" -and
        $_.AssignedLicenses.Count -gt 0
    } |
    Select-Object -ExpandProperty UserPrincipalName

Write-Host "Found $($users.Count) licensed users."

# Submit OneDrive provisioning requests in batches
$batchSize = 200

for ($i = 0; $i -lt $users.Count; $i += $batchSize) {
    $batch = $users[$i..([Math]::Min($i + $batchSize - 1, $users.Count - 1))]
    Request-SPOPersonalSite -UserEmails $batch
    Write-Host "Submitted batch $([Math]::Floor($i / $batchSize) + 1)"
}

Write-Host "OneDrive provisioning requests have been submitted."
```

* Check in the admin portal for the provisioned OneDrive sites