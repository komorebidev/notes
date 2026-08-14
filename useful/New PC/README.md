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

# ========================================
# Application installations
# ========================================

$apps = @(
    @{ Id = "AgileBits.1Password"; Name = "1Password" },
    @{ Id = "Microsoft.PowerShell"; Name = "PowerShell" },
    @{ Id = "GitHub.cli"; Name = "GitHub CLI" },
    @{ Id = "Git.Git"; Name = "Git" },
    @{ Id = "Mozilla.Firefox"; Name = "Firefox" },
    @{ Id = "Microsoft.PowerAutomateDesktop"; Name = "Power Automate for desktop" }
)

foreach ($app in $apps) {
    Write-Host "Checking for $($app.Name)..." -ForegroundColor Cyan

    $installed = winget list `
        --id $app.Id `
        --exact `
        --accept-source-agreements 2>&1

    if ($installed -match [regex]::Escape($app.Id)) {
        Write-Host "$($app.Name) is already installed. Skipping." -ForegroundColor Yellow
    }
    else {
        Write-Host "Installing $($app.Name)..." -ForegroundColor Green

        winget install `
            --id $app.Id `
            --exact `
            --silent `
            --disable-interactivity `
            --accept-source-agreements `
            --accept-package-agreements

        if ($LASTEXITCODE -ne 0) {
            Write-Host "$($app.Name) installation failed." -ForegroundColor Red
            exit 1
        }
    }

    Write-Host "----------------------------------------"
}


# ========================================
# Install Python 3.14
# ========================================

Write-Host "Checking for Python 3.14..." -ForegroundColor Cyan

$pythonInstalled = winget list `
    --id Python.Python.3.14 `
    --exact `
    --accept-source-agreements 2>&1

if ($pythonInstalled -match "Python.Python.3.14") {
    Write-Host "Python 3.14 is already installed. Skipping." -ForegroundColor Yellow
}
else {
    Write-Host "Installing Python 3.14..." -ForegroundColor Green

    winget install `
        --id Python.Python.3.14 `
        --exact `
        --silent `
        --disable-interactivity `
        --accept-package-agreements `
        --accept-source-agreements

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Python installation failed." -ForegroundColor Red
        exit 1
    }
}

Write-Host "----------------------------------------"


# ========================================
# Refresh PATH
# ========================================

Write-Host "Refreshing PATH..." -ForegroundColor Cyan

$env:Path = `
    [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
    [System.Environment]::GetEnvironmentVariable("Path", "User")


# ========================================
# Install Python Playwright
# ========================================

Write-Host "Checking for Python Playwright..." -ForegroundColor Cyan

$playwrightPython = python -m pip show playwright 2>&1

if ($playwrightPython -match "^Name:\s+playwright") {
    Write-Host "Python Playwright is already installed. Skipping." -ForegroundColor Yellow
}
else {
    Write-Host "Installing Python Playwright..." -ForegroundColor Green

    python -m pip install playwright

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Python Playwright installation failed." -ForegroundColor Red
        exit 1
    }
}

Write-Host "----------------------------------------"


# ========================================
# Install Node.js LTS
# ========================================

Write-Host "Checking for Node.js LTS..." -ForegroundColor Cyan

$nodeInstalled = winget list `
    --id OpenJS.NodeJS.LTS `
    --exact `
    --accept-source-agreements 2>&1

if ($nodeInstalled -match "OpenJS.NodeJS.LTS") {
    Write-Host "Node.js LTS is already installed. Skipping." -ForegroundColor Yellow
}
else {
    Write-Host "Installing Node.js LTS..." -ForegroundColor Green

    winget install `
        --id OpenJS.NodeJS.LTS `
        --exact `
        --silent `
        --disable-interactivity `
        --accept-package-agreements `
        --accept-source-agreements

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Node.js installation failed." -ForegroundColor Red
        exit 1
    }
}

Write-Host "----------------------------------------"


# ========================================
# Refresh PATH again
# ========================================

Write-Host "Refreshing PATH..." -ForegroundColor Cyan

$env:Path = `
    [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
    [System.Environment]::GetEnvironmentVariable("Path", "User")


# ========================================
# Install Playwright CLI
# ========================================

Write-Host "Checking for Playwright CLI..." -ForegroundColor Cyan

$playwrightCliInstalled = npm list -g --depth=0 @playwright/cli 2>&1

if ($playwrightCliInstalled -match "@playwright/cli") {
    Write-Host "Playwright CLI is already installed. Skipping." -ForegroundColor Yellow
}
else {
    Write-Host "Installing Playwright CLI..." -ForegroundColor Green

    npm install -g @playwright/cli@latest

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Playwright CLI installation failed." -ForegroundColor Red
        exit 1
    }
}

Write-Host "----------------------------------------"


# ========================================
# Verify installations
# ========================================

Write-Host "Verifying installations..." -ForegroundColor Cyan

Write-Host ""
Write-Host "Python:" -ForegroundColor Cyan
python --version

Write-Host ""
Write-Host "Node.js:" -ForegroundColor Cyan
node --version

Write-Host ""
Write-Host "npm:" -ForegroundColor Cyan
npm --version

Write-Host ""
Write-Host "Playwright CLI:" -ForegroundColor Cyan
playwright-cli --version

Write-Host ""
Write-Host "Python Playwright:" -ForegroundColor Cyan
python -c "import playwright; print('Playwright Python package installed')"

Write-Host ""
Write-Host "========================================"
Write-Host "Core installations complete!" -ForegroundColor Green
Write-Host "========================================"


# ========================================
# Playwright Edge Extension
# ========================================

Write-Host ""
Write-Host "Checking Playwright Edge extension..." -ForegroundColor Cyan

Write-Host ""
Write-Host "The Playwright Edge extension must be installed in Edge." -ForegroundColor Yellow
Write-Host "It is used to attach Playwright to your existing Edge tabs and" -ForegroundColor Yellow
Write-Host "reuse your existing Microsoft SSO session." -ForegroundColor Yellow
Write-Host ""

$extensionCheck = Read-Host "Is the Playwright extension already installed in Edge? (Y/N)"

if ($extensionCheck -match "^[Yy]$") {
    Write-Host "Playwright Edge extension confirmed." -ForegroundColor Green
}
else {
    Write-Host ""
    Write-Host "Please install the official Playwright extension in Microsoft Edge." -ForegroundColor Yellow
    Write-Host "After installation, return here and press Enter." -ForegroundColor Yellow

    Start-Process "msedge.exe" "edge://extensions"

    Read-Host "Press Enter once the Playwright extension is installed"

    Write-Host "Playwright Edge extension setup completed." -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================"
Write-Host "All installations complete!" -ForegroundColor Green
Write-Host "========================================"

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