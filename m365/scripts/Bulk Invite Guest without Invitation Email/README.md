# Bulk Invite Guest without invitation email 

## KB Reference

* https://learn.microsoft.com/en-us/entra/external-id/bulk-invite-powershell

* https://learn.microsoft.com/en-us/entra/external-id/tutorial-bulk-invite

## Script

```powershell

 # ==========================================
# 0. MODULE CHECK & INSTALLATION
# ==========================================

$RequiredModules = @(
    "Microsoft.Graph.Identity.SignIns"
    "Microsoft.Graph.Users"
)

foreach ($Module in $RequiredModules) {
    # Check if the module is available on the machine
    if (-not (Get-Module -ListAvailable -Name $Module)) {
        Write-Host "Module '$Module' not found. Installing now..." -ForegroundColor Cyan

        # -Force bypasses the "untrusted repository" prompt for PSGallery
        # -Scope CurrentUser means you don't need to run PowerShell as Administrator
        Install-Module -Name $Module -Scope CurrentUser -Force -AllowClobber
    }
    else {
        Write-Host "Module '$Module' is already installed." -ForegroundColor Green
    }

    # Import the module so it's ready to use
    Import-Module $Module
}

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan

# ==========================================
# 1. AUTHENTICATION
# ==========================================

Connect-MgGraph -Scopes "User.Invite.All", "User.Read.All"

$CsvPath = "C:\tmp\test_guests.csv"
$GuestUsers = Import-Csv $CsvPath

Write-Host "Processing guest users..." -ForegroundColor Cyan

$Results = foreach ($Guest in $GuestUsers) {

    # ==========================================
    # 2. DUPLICATE CHECK
    # ==========================================

    $ExistingUser = $null

    try {
        $ExistingUser = Get-MgUser -Filter "mail eq '$($Guest.EmailAddress)'" -ErrorAction Stop
    }
    catch {
        # Ignoring read errors here to allow the script to proceed
    }

    if ($ExistingUser) {
        [PSCustomObject]@{
            DisplayName = $Guest.DisplayName
            Email       = $Guest.EmailAddress
            Status      = "Skipped (Already Exists)"
            UserId      = $ExistingUser.Id
            Error       = "None"
        }

        continue
    }

    # ==========================================
    # 3. INVITATION PROCESS
    # ==========================================

    $InviteParams = @{
        InvitedUserDisplayName  = $Guest.DisplayName
        InvitedUserEmailAddress = $Guest.EmailAddress
        InviteRedirectUrl       = "https://myapps.microsoft.com"
        SendInvitationMessage   = $false
    }

    try {
        $InviteResult = New-MgInvitation -BodyParameter $InviteParams -ErrorAction Stop

        [PSCustomObject]@{
            DisplayName = $Guest.DisplayName
            Email       = $Guest.EmailAddress
            Status      = "Created (No Email Sent)"
            UserId      = $InviteResult.InvitedUser.Id
            Error       = "None"
        }
    }
    catch {
        # ==========================================
        # 4. FAILURE HANDLING
        # ==========================================

        $GraphError = $_.ErrorDetails.Message
        $ErrorMessage = if ($GraphError) {
            $GraphError
        }
        else {
            $_.Exception.Message
        }

        [PSCustomObject]@{
            DisplayName = $Guest.DisplayName
            Email       = $Guest.EmailAddress
            Status      = "Failed"
            UserId      = "N/A"
            Error       = $ErrorMessage
        }
    }
}

$Results | Export-Csv ".\GuestImportResults.csv" -NoTypeInformation -Encoding UTF8

Write-Host "Migration script complete. Results saved to .\GuestImportResults.csv" -ForegroundColor Green

```