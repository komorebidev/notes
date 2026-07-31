# New PC

* Add below packages through winget to make things easier

```
winget install --id AgileBits.1Password -e --silent
winget install --id Microsoft.PowerShell -e --silent
winget install --id GitHub.cli -e --silent
winget install --id Git.Git -e --silent
winget install --id GnuWin32.CoreUtils -e --silent
winget install --id Microsoft.VisualStudio.2022.Community -e --silent

# ==========================================================
# PowerToys Clean Redeploy + Awake Configuration
# ==========================================================

Write-Output "=== PowerToys Deployment Script Starting ==="


# ==========================================================
# Check existing PowerToys installation
# ==========================================================

Write-Output ""
Write-Output "Checking for existing PowerToys installation..."

$installedPowerToys = winget list --id Microsoft.PowerToys --source winget 2>$null


if ($installedPowerToys -match "PowerToys") {

    Write-Output "Existing PowerToys installation detected."

    Write-Output "Stopping PowerToys processes..."

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


    Write-Output "Previous PowerToys removed."

}
else {

    Write-Output "No existing PowerToys installation found."

}



# ==========================================================
# Install PowerToys
# ==========================================================

Write-Output ""
Write-Output "Installing Microsoft PowerToys..."

winget install `
    --id Microsoft.PowerToys `
    --source winget `
    --silent `
    --disable-interactivity `
    --accept-package-agreements `
    --accept-source-agreements


Start-Sleep -Seconds 10



# ==========================================================
# Find PowerToys settings JSON
# ==========================================================

Write-Output ""
Write-Output "Searching for PowerToys configuration files..."


$searchPaths = @(
    "$env:LOCALAPPDATA\Microsoft\PowerToys",
    "$env:APPDATA\Microsoft\PowerToys"
)


$jsonFiles = foreach ($path in $searchPaths) {

    if (Test-Path $path) {

        Get-ChildItem `
            -Path $path `
            -Recurse `
            -Filter "*.json" `
            -File `
            -ErrorAction SilentlyContinue
    }
}



if (-not $jsonFiles) {

    Write-Output "No JSON settings found."
    Write-Output "Starting PowerToys once to generate configuration..."

    throw "Run PowerToys once before applying configuration."
}



# ==========================================================
# Find Awake module
# ==========================================================

Write-Output "Searching for Awake module..."


$awakeFile = $null
$jsonRoot = $null
$awakeModule = $null



foreach ($file in $jsonFiles) {

    try {

        $json = Get-Content $file.FullName -Raw |
            ConvertFrom-Json


        foreach ($property in $json.PSObject.Properties) {


            if ($property.Value.name -eq "Awake") {

                $awakeFile = $file.FullName
                $jsonRoot = $json
                $awakeModule = $property.Value

                break
            }
        }


        if ($awakeModule) {
            break
        }

    }
    catch {

        continue
    }
}



if (-not $awakeModule) {

    Write-Output "Awake module was not found."
    Write-Output "Files scanned:"
    $jsonFiles.FullName

    throw "Unable to locate Awake configuration."
}



Write-Output "Awake configuration found:"
Write-Output $awakeFile



# ==========================================================
# Backup configuration
# ==========================================================

Copy-Item `
    $awakeFile `
    "$awakeFile.backup" `
    -Force



# ==========================================================
# Configure Awake
# ==========================================================

Write-Output ""
Write-Output "Applying Awake configuration..."


$awakeModule.properties.keepDisplayOn = $true
$awakeModule.properties.mode = 1

$awakeModule.properties.intervalHours = 0
$awakeModule.properties.intervalMinutes = 0
$awakeModule.properties.expirationDateTime = $null



Write-Output "Awake settings:"
Write-Output "- Keep display on: Enabled"
Write-Output "- Mode: Indefinite"



# Save configuration

$jsonRoot |
    ConvertTo-Json -Depth 100 |
    Set-Content `
        -Path $awakeFile `
        -Encoding UTF8



Write-Output "Settings saved."



# ==========================================================
# Enable PowerToys startup
# ==========================================================

Write-Output ""
Write-Output "Enabling PowerToys startup..."


$startupKey = `
"HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"


# Find executable

$powerToysExe = $null


$pathLookup = Get-Command `
    "PowerToys.exe" `
    -ErrorAction SilentlyContinue


if ($pathLookup) {

    $powerToysExe = $pathLookup.Source
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
                -Recurse `
                -File `
                -ErrorAction SilentlyContinue |
                Select-Object -First 1


            if ($found) {

                $powerToysExe = $found.FullName
                break
            }
        }
    }
}



if ($powerToysExe) {


    New-ItemProperty `
        -Path $startupKey `
        -Name "PowerToys" `
        -Value "`"$powerToysExe`" --startup" `
        -PropertyType String `
        -Force |
        Out-Null


    Write-Output "Startup enabled."

}
else {

    Write-Output "PowerToys executable not found for startup registration."

}



# ==========================================================
# Restart PowerToys
# ==========================================================

Write-Output ""
Write-Output "Restarting PowerToys..."


try {


    Get-Process `
        -Name "PowerToys" `
        -ErrorAction SilentlyContinue |
        Stop-Process `
        -Force `
        -ErrorAction SilentlyContinue


    Start-Sleep -Seconds 3



    if (-not $powerToysExe) {

        throw "PowerToys executable not found."
    }



    Start-Process `
        -FilePath $powerToysExe `
        -ArgumentList "--startup" `
        -WorkingDirectory (Split-Path $powerToysExe) `
        -WindowStyle Hidden



    Write-Output "PowerToys restarted successfully."

}
catch {

    Write-Output "Restart failed:"
    Write-Output $_.Exception.Message

}



Write-Output ""
Write-Output "=== Deployment Complete ==="


Read-Host "Press ENTER to close"
```

* Might need to install Git from the exe to add unix tools
