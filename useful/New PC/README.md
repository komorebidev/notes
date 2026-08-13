# New PC

## Debloat and add packages through winget to make things easier

```
Write-Host "Starting Cloud PC bloatware removal..." -ForegroundColor Cyan

# List of consumer and non-essential apps common in cloud environments to remove
$AppsToRemove = @(
    "*Microsoft.XboxApp*",
    "*Microsoft.XboxGamingOverlay*",
    "*Microsoft.XboxGameOverlay*",
    "*Microsoft.XboxIdentityProvider*",
    "*Microsoft.XboxSpeechToTextOverlay*",
    "*Microsoft.ZuneMusic*",
    "*Microsoft.ZuneVideo*",
    "*Microsoft.MicrosoftSolitaireCollection*",
    "*Microsoft.BingNews*",
    "*Microsoft.BingWeather*",
    "*Microsoft.GetHelp*",
    "*Microsoft.Getstarted*",
    "*Microsoft.People*",
    "*Microsoft.Todos*",
    "*Microsoft.PowerAutomateDesktop*",
    "*Clipchamp.Clipchamp*"
)

foreach ($app in $AppsToRemove) {
    # Remove for the current user
    Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
    
    # Remove provisioned package so it doesn't reinstall for new users (crucial for Cloud PCs)
    Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $app | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

Write-Host "Cloud PC app cleanup finished successfully! Microsoft Store was preserved." -ForegroundColor Green

$apps = @(
    @{ Id = "AgileBits.1Password"; Name = "1Password" },
    @{ Id = "Microsoft.PowerShell"; Name = "PowerShell" },
    @{ Id = "GitHub.cli"; Name = "GitHub CLI" },
    @{ Id = "Git.Git"; Name = "Git" },
    @{ Id = "Mozilla.Firefox"; Name = "Firefox" }
    @{ Id = "Microsoft.PowerAutomateDesktop"; Name = "Power Automate for desktop" }
)

foreach ($app in $apps) {
    Write-Host "Checking for $($app.Name)..." -ForegroundColor Cyan
    
    # Check if the app is already installed via winget
    $installed = winget list --id $app.Id --exact --accept-source-agreements 2>&1
    
    if ($installed -match $app.Id) {
        Write-Host "$($app.Name) is already installed. Skipping." -ForegroundColor Yellow
    } else {
        Write-Host "Installing $($app.Name)..." -ForegroundColor Green
        winget install --id $app.Id -e --silent --accept-source-agreements --accept-package-agreements
    }
    
    Write-Host "----------------------------------------"
}

Write-Host "All installations complete!" -ForegroundColor Green

# ==========================================================
# PowerToys Silent Redeploy
# No Awake configuration changes
# ==========================================================

Write-Output "=== PowerToys Deployment Starting ==="


# ==========================================================
# Check existing installation
# ==========================================================

Write-Output ""
Write-Output "Checking for existing PowerToys installation..."

$installed = winget list --id Microsoft.PowerToys --source winget 2>$null


if ($installed -match "PowerToys") {

    Write-Output "Existing PowerToys installation found."

    Write-Output "Stopping PowerToys..."

    Get-Process -Name "PowerToys" -ErrorAction SilentlyContinue |
        Stop-Process -Force -ErrorAction SilentlyContinue

    Get-Process -Name "PowerToys.Settings" -ErrorAction SilentlyContinue |
        Stop-Process -Force -ErrorAction SilentlyContinue


    Start-Sleep -Seconds 3


    Write-Output "Uninstalling PowerToys..."

    winget uninstall `
        --id Microsoft.PowerToys `
        --source winget `
        --silent `
        --disable-interactivity `
        --accept-source-agreements


    Start-Sleep -Seconds 5


    Write-Output "Removing old PowerToys settings..."

    Remove-Item `
        "$env:LOCALAPPDATA\Microsoft\PowerToys" `
        -Recurse `
        -Force `
        -ErrorAction SilentlyContinue

}
else {

    Write-Output "No existing PowerToys installation found."

}



# ==========================================================
# Install PowerToys silently
# ==========================================================

Write-Output ""
Write-Output "Installing PowerToys silently..."


winget install `
    --id Microsoft.PowerToys `
    --source winget `
    --silent `
    --disable-interactivity `
    --accept-package-agreements `
    --accept-source-agreements



Start-Sleep -Seconds 10



# ==========================================================
# Find PowerToys executable
# ==========================================================

Write-Output ""
Write-Output "Finding PowerToys executable..."


$powerToysExe = $null


$cmd = Get-Command PowerToys.exe -ErrorAction SilentlyContinue


if ($cmd) {

    $powerToysExe = $cmd.Source
}



if (-not $powerToysExe) {


    $searchLocations = @(
        "$env:ProgramFiles",
        "${env:ProgramFiles(x86)}",
        "$env:LOCALAPPDATA"
    )


    foreach ($location in $searchLocations) {


        if (Test-Path $location) {


            $found = Get-ChildItem `
                -Path $location `
                -Filter "PowerToys.exe" `
                -File `
                -Recurse `
                -ErrorAction SilentlyContinue |
                Select-Object -First 1


            if ($found) {

                $powerToysExe = $found.FullName
                break
            }
        }
    }
}



if (-not $powerToysExe) {

    Write-Output "ERROR: PowerToys executable not found."
    Read-Host "Press ENTER to close"
    exit 1
}


Write-Output "Found:"
Write-Output $powerToysExe



# ==========================================================
# Enable startup
# ==========================================================

Write-Output ""
Write-Output "Enabling PowerToys startup..."


$startupPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"


New-ItemProperty `
    -Path $startupPath `
    -Name "PowerToys" `
    -Value "`"$powerToysExe`" --startup" `
    -PropertyType String `
    -Force |
    Out-Null



# ==========================================================
# Start PowerToys silently
# ==========================================================

Write-Output ""
Write-Output "Starting PowerToys..."


Start-Process `
    -FilePath $powerToysExe `
    -ArgumentList "--startup" `
    -WorkingDirectory (Split-Path $powerToysExe) `
    -WindowStyle Hidden



Write-Output ""
Write-Output "=== PowerToys Deployment Complete ==="


Read-Host "Press ENTER to close"
```

* Might need to install Git from the exe to add unix tools

## Adding git pull to explorer (run in admin Powershell)

```powershell
# Ensure the script is running with Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Please run this script as an Administrator!"
    Exit
}

# Ensure the HKCR drive exists
if (!(Test-Path HKCR:)) {
    New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
}

$menuName = "Git Pull Here"

# Commands that change location, run git pull, and pause so you can see the output
$bgCommand  = 'powershell.exe -NoProfile -Command "Set-Location -LiteralPath ''%V''; git pull; Read-Host ''Press Enter to close''"'
$dirCommand = 'powershell.exe -NoProfile -Command "Set-Location -LiteralPath ''%1''; git pull; Read-Host ''Press Enter to close''"'

# Helper function to create registry paths and properties safely
function Set-RegistryKey {
    param([string]$Path, [string]$Name, [string]$Value, [string]$PropertyType = "String")
    if (!(Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
    
    if ([string]::IsNullOrEmpty($Name)) {
        # Set the default (unnamed) value of the key
        Set-Item -Path $Path -Value $Value
    } else {
        # Set named properties (like Icon)
        New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $PropertyType -Force | Out-Null
    }
}

# 1. Setup for Directory Background (Right-clicking empty space inside a folder)
$bgPath = "HKCR:\Directory\Background\shell\GitPullHere"
Set-RegistryKey $bgPath "" $menuName
Set-RegistryKey $bgPath "Icon" "git.exe"
Set-RegistryKey "$bgPath\command" "" $bgCommand

# 2. Setup for Directory (Right-clicking a folder itself)
$dirPath = "HKCR:\Directory\shell\GitPullHere"
Set-RegistryKey $dirPath "" $menuName
Set-RegistryKey $dirPath "Icon" "git.exe"
Set-RegistryKey "$dirPath\command" "" $dirCommand

Write-Output "Successfully added 'Git Pull Here' to the Windows Explorer context menu!"
```