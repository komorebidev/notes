# Get OneDrive Source List

* The PowerShell used for OneDrive migrations uses "source list" as part of the parameter
* If the tenant language is not English, then this parameter changes
* Make sure to save any scripts in encoding that supports the language
* Otherwise, will chase error forever
* And no support teams can help

```powershell
PS C:\tmp> $site = Connect-Site `
    -Url "https://starasiaenterprises-my.sharepoint.com/personal/aina_nayuki_polaris-holdings_com/" `
    -ModernAuth

WARNING: A web browser will open at https://login.microsoftonline.com/organizations/oauth2/v2.0/authorize.
Please continue the login in the web browser.

PS C:\tmp> Get-List -Site $site

Id                  : 945e8513-4a16-4cae-9647-b2169efc25c3
Title               : ソーシャル
Address             : https://starasiaenterprises-my.sharepoint.com/personal/aina_nayuki_polaris-holdings_com/Social/
BaseType            : List
Source              : /personal/aina_nayuki_polaris-holdings_com/
ContentApproval     : False
RootFolder          : /personal/aina_nayuki_polaris-holdings_com/Social/
EnableAttachments   : True
EnableVersioning    : False
EnableMinorVersions : False
ForceCheckout       : False
Site                : https://starasiaenterprises-my.sharepoint.com/personal/aina_nayuki_polaris-holdings_com/

Id                  : d82397ae-dba4-412c-b03b-5ebce6c1b6e7
Title               : ドキュメント
Address             : https://starasiaenterprises-my.sharepoint.com/personal/aina_nayuki_polaris-holdings_com/Documents/
BaseType            : Document library
Source              : /personal/aina_nayuki_polaris-holdings_com/
ContentApproval     : False
RootFolder          : /personal/aina_nayuki_polaris-holdings_com/Documents/
EnableAttachments   : False
EnableVersioning    : True
EnableMinorVersions : False
ForceCheckout       : False
Site                : https://starasiaenterprises-my.sharepoint.com/personal/aina_nayuki_polaris-holdings_com/
```