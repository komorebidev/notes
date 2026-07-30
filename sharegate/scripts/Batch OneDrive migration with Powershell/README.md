# Batch OneDrive migration with Powershell

* Sharegate UI does not support batch
* Needs to be done by script
* There are multiple options such as incremental


## Reference

* https://help.sharegate.com/en/articles/10236381-migrate-onedrive-for-business-to-onedrive-for-business-with-powershell

## Sample

```powershell
Import-Module Sharegate

# Define the CSV file path
$csvFile = "C:\CSV\CopyContent.csv"

# Import the CSV file
$table = Import-Csv $csvFile -Delimiter ","

# Define the source and destination connections
$srcSiteConnection = Connect-Site -Url "https://sourcetenantname-my.sharepoint.com/" -ModernAuth
$dstSiteConnection = Connect-Site -Url "https://destinationtenantname-my.sharepoint.com/" -ModernAuth

# Set variables for site and list operations
Set-Variable srcSite, dstSite, srcList, dstList

# Loop through each row in the CSV
foreach ($row in $table) {
    # Clear previous values of variables
    Clear-Variable srcSite
    Clear-Variable dstSite
    Clear-Variable srcList
    Clear-Variable dstList

    # Connect to source and destination sites
    $srcSite = Connect-Site -Url $row.SourceSite -UseCredentialsFrom $srcSiteConnection
    $dstSite = Connect-Site -Url $row.DestinationSite -UseCredentialsFrom $dstSiteConnection

    # Get source and destination lists
    $srcList = Get-List -Site $srcSite -Name "Documents"
    $dstList = Get-List -Site $dstSite -Name "Documents"

    # Copy content from source list to destination list
    Copy-Content -SourceList $srcList -DestinationList $dstList

    # Remove site collection administrator permissions
    Remove-SiteCollectionAdministrator -Site $srcSite
    Remove-SiteCollectionAdministrator -Site $dstSite
}
```