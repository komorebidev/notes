# Windows Sandbox

* For testing Intune enrollments and app deployments
* Run as admin Powershell (below Powershell 7)

```powershell
# Check if running as Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Please run this script as an Administrator!" -ForegroundColor Red
    Exit
}

Write-Host "Checking Windows Sandbox status..." -ForegroundColor Cyan

# Check if the feature is enabled
$sandboxFeature = Get-WindowsOptionalFeature -Online -FeatureName "Containers-DisposableClientVM"

if ($sandboxFeature.State -eq "Enabled") {
    Write-Host "Windows Sandbox is already enabled." -ForegroundColor Green
} else {
    Write-Host "Windows Sandbox is disabled. Enabling it now..." -ForegroundColor Yellow
    
    Enable-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -Online -NoRestart -Verbose
    
    Write-Host "Windows Sandbox has been enabled successfully!" -ForegroundColor Green
    Write-Host "A system restart is required for the changes to take effect." -ForegroundColor Magenta
    
    $restart = Read-Host "Would you like to restart now? (Y/N)"
    if ($restart -eq 'Y' -or $restart -eq 'y') {
        Restart-Computer -Force
    }
}
```