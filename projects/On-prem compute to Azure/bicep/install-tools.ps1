# C:\temp\install-tools.ps1
$tempDir = "C:\temp"
if (!(Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir | Out-Null
}

if (!(Get-Command "winget" -ErrorAction SilentlyContinue)) {
    Write-Host "Installing WinGet package manager..."
    $progressPreference = 'silentlyContinue'
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201.5 -Force | Out-Null
    Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null
    Repair-WinGetPackageManager -AllUsers
}

$apps = @(
    @{ Name = "VS Code"; Id = "Microsoft.VisualStudioCode" },
    @{ Name = "Python 3.11"; Id = "Python.Python.3.11" },
    @{ Name = "MySQL Workbench"; Id = "Oracle.MySQLWorkbench" }
)

foreach ($app in $apps) {
    Write-Host "Checking if $($app.Name) is already installed..."
    $isInstalled = winget list --id $app.Id --exact 2>&1
    
    if ($isInstalled -match $app.Id) {
        Write-Host "$($app.Name) is already installed. Skipping..."
    } else {
        Write-Host "$($app.Name) not found. Installing..."
        winget install --id $app.Id --exact --silent --accept-package-agreements --accept-source-agreements
    }
}