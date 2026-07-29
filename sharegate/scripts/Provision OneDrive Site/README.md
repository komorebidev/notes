# Provision OneDrive Site

* Sometimes user accounts on destination tenant do not have a site associated
* This means they cannot be selected as a migration target from Sharegate GUI
* To fix this, just pre-provision for the whole tenant
* Any accounts with an existing site get skipped

## Script

```powershell
# Install the SharePoint Online Management Shell module
Install-Module `
    -Name Microsoft.Online.SharePoint.PowerShell `
    -Scope CurrentUser `
    -Force

# Connect to the SharePoint Online Admin Center
Connect-SPOService

# Request creation of a OneDrive personal site
Request-SPOPersonalSite `
    -UserEmails "xxx@email.com"
```