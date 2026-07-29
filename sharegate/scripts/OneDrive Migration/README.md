# OneDrive Migration

* For automated migration, scripts are needed
* The Sharegate GUI supports one by one only

## Script sample

```powershell
# NOTE:
# Save this script as UTF-8 with BOM (.ps1)

Import-Module ShareGate

$CopySettings = New-CopySettings -OnContentItemExists IncrementalUpdate

$CsvFile = "C:\tmp\migration.csv"
$Table = Import-Csv $CsvFile -Delimiter ","

$SrcSiteConnection = Connect-Site `
    -Url "https://starasiaenterprises-my.sharepoint.com/" `
    -ModernAuth

$DstSiteConnection = Connect-Site `
    -Url "https://polarishd-my.sharepoint.com/" `
    -ModernAuth

Set-Variable srcSite, dstSite, srcList, dstList

foreach ($Row in $Table) {
    Clear-Variable srcSite -ErrorAction SilentlyContinue
    Clear-Variable dstSite -ErrorAction SilentlyContinue
    Clear-Variable srcList -ErrorAction SilentlyContinue
    Clear-Variable dstList -ErrorAction SilentlyContinue

    $srcSite = Connect-Site `
        -Url $Row.SourceSite `
        -UseCredentialsFrom $SrcSiteConnection

    $dstSite = Connect-Site `
        -Url $Row.DestinationSite `
        -UseCredentialsFrom $DstSiteConnection

    $srcList = Get-List `
        -Site $srcSite `
        -Name "ドキュメント"

    $dstList = Get-List `
        -Site $dstSite `
        -Name "ドキュメント"

    Copy-Content `
        -SourceList $srcList `
        -DestinationList $dstList `
        -CopySettings $CopySettings
}

# Remove site collection administrator permissions
# Remove-SiteCollectionAdministrator -Site $srcSite
# Remove-SiteCollectionAdministrator -Site $dstSite
```