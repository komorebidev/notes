```powershell
# C:\temp\install-tools.ps1

$tempDir = "C:\temp"

# Create temp directory if it doesn't exist
if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
}

Write-Host "=== Installing development tools ==="

# ------------------------------------------------------------
# Ensure WinGet is available
# ------------------------------------------------------------
if (-not (Get-Command "winget" -ErrorAction SilentlyContinue)) {

    Write-Host "WinGet not found. Installing WinGet package manager..."

    $ProgressPreference = 'SilentlyContinue'

    try {
        # Install NuGet provider
        Install-PackageProvider `
            -Name NuGet `
            -MinimumVersion 2.8.5.201 `
            -Force `
            -ErrorAction Stop | Out-Null

        # Install Microsoft.WinGet.Client module
        Install-Module `
            -Name Microsoft.WinGet.Client `
            -Force `
            -Repository PSGallery `
            -ErrorAction Stop | Out-Null

        # Repair/install WinGet
        Repair-WinGetPackageManager -AllUsers -ErrorAction Stop

        Write-Host "WinGet installation completed."
    }
    catch {
        Write-Error "Failed to install WinGet: $($_.Exception.Message)"
        exit 1
    }
}

# Verify WinGet
$wingetPath = (Get-Command winget -ErrorAction SilentlyContinue).Source

if (-not $wingetPath) {
    Write-Error "WinGet is still not available after installation."
    exit 1
}

Write-Host "WinGet found: $wingetPath"
winget --version

# ------------------------------------------------------------
# Configure WinGet
# ------------------------------------------------------------

Write-Host "Updating WinGet sources..."

winget source update `
    --source winget `
    --disable-interactivity

if ($LASTEXITCODE -ne 0) {
    Write-Warning "WinGet source update returned exit code $LASTEXITCODE. Continuing..."
}

# ------------------------------------------------------------
# Applications to install
# ------------------------------------------------------------

$apps = @(
    @{
        Name = "VS Code"
        Id   = "Microsoft.VisualStudioCode"
    },
    @{
        Name = "Python 3.11"
        Id   = "Python.Python.3.11"
    },
    @{
        Name = "MySQL Workbench"
        Id   = "Oracle.MySQLWorkbench"
    }
)

# ------------------------------------------------------------
# Install applications
# ------------------------------------------------------------

foreach ($app in $apps) {

    Write-Host ""
    Write-Host "========================================"
    Write-Host "Checking: $($app.Name)"
    Write-Host "Package ID: $($app.Id)"
    Write-Host "========================================"

    # Check whether application is already installed.
    # Explicitly use the winget source so msstore cannot prompt.
    $isInstalled = winget list `
        --id $app.Id `
        --exact `
        --source winget `
        --disable-interactivity `
        2>&1

    if ($isInstalled -match [regex]::Escape($app.Id)) {

        Write-Host "$($app.Name) is already installed. Skipping."

    }
    else {

        Write-Host "$($app.Name) not found. Installing..."

        winget install `
            --id $app.Id `
            --exact `
            --source winget `
            --silent `
            --accept-package-agreements `
            --accept-source-agreements `
            --disable-interactivity

        if ($LASTEXITCODE -eq 0) {
            Write-Host "$($app.Name) installed successfully."
        }
        else {
            Write-Error "Failed to install $($app.Name). Exit code: $LASTEXITCODE"
        }
    }
}

Write-Host ""
Write-Host "=== Installation process completed ==="
```