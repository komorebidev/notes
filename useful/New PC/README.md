# New PC

* Add below packages through winget to make things easier

```
winget install --id AgileBits.1Password -e --silent
winget install --id Microsoft.PowerShell -e --silent
winget install --id GitHub.cli -e --silent
winget install --id Git.Git -e --silent
winget install --id GnuWin32.CoreUtils -e --silent
winget install --id Microsoft.VisualStudio.2022.Community -e --silent
winget install --id Microsoft.PowerToys --source winget --accept-package-agreements --accept-source-agreements

$settingsPath = "$env:LOCALAPPDATA\Microsoft\PowerToys\Awake\settings.json"
$settingsFolder = Split-Path $settingsPath

if (-not (Test-Path $settingsFolder)) {
    Write-Output "ERROR: PowerToys Awake settings path was not found:"
    Write-Output $settingsFolder
    Write-Output "Please update the script with the correct PowerToys settings path."
    exit 1
}

@'
{
  "properties": {
    "mode": 2,
    "keepDisplayOn": true
  }
}
'@ | Out-File -Encoding utf8 $settingsPath

Write-Output "PowerToys Awake has been configured to stay awake indefinitely with the screen kept on."
```

* Might need to install Git from the exe to add unix tools
