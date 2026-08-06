# Microsoft Graph Basics

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