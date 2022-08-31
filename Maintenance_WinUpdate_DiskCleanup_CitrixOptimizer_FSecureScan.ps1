Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force
cd $PSScriptRoot
$Computername = hostname
Add-Type -AssemblyName System.Windows.Forms
$browser = New-Object System.Windows.Forms.FolderBrowserDialog
$null = $browser.ShowDialog()
$path = $browser.SelectedPath

$update = {

Install-PackageProvider -Name NuGet -Force
Install-Module -Name PSWindowsUpdate -Force
ECHO Y | Powershell Get-WindowsUpdate -AcceptAll -Download -Install -MicrosoftUpdate
write-host "FF wachten, pizza!"
Start-Sleep -Seconds 10

}

$diskcleanup = {

Write-Host 'Clearing CleanMgr.exe automation settings.'
Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\*' -Name StateFlags0001 -ErrorAction SilentlyContinue | Remove-ItemProperty -Name StateFlags0001 -ErrorAction SilentlyContinue

#Write-Host 'Enabling Update Cleanup. This is done automatically in Windows 10 via a scheduled task.'
#New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Update Cleanup' -Name StateFlags0001 -Value 2 -PropertyType DWord

Write-Host 'Enabling Temporary Files Cleanup.'
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files' -Name StateFlags0001 -Value 2 -PropertyType DWord

Write-Host 'Starting CleanMgr.exe...'
Start-Process -FilePath CleanMgr.exe -ArgumentList '/sagerun:1' -WindowStyle Hidden -Wait

Write-Host 'Waiting for CleanMgr and DismHost processes. Second wait neccesary as CleanMgr.exe spins off separate processes.'
Get-Process -Name cleanmgr,dismhost -ErrorAction SilentlyContinue | Wait-Process
}

$Citrixoptimizer = {
    
     .\CtxOptimizerEngine.ps1 -Source Citrix_Windows_Server_2022_2009.xml -Mode Execute

}

$componenstorecleanup = {

    DISM.exe /online /cleanup-image /startcomponentcleanup
    
}

$FSecure = {

$folder = 'C:\Program Files (x86)\F-Secure\'
if (Test-Path -Path $folder) {

    cd 'C:\Program Files (x86)\F-Secure\psb\'
    .\fsscan.exe -d C:\}
else {

    Start-MpScan -ScanType FullScan
    }
}

Invoke-Command -ScriptBlock $update
##Disk cleanup script werkt nog niet goed, maar meeste waarvoor we dit doen wordt in de componentstorecleanup opgepakt##
#Invoke-Command -ScriptBlock $diskcleanup 
Invoke-Command -ScriptBlock $componentstorecleanup
Invoke-Command -ScriptBlock $Citrixoptimizer
Invoke-Command -ScriptBlock $FSecure
##Wegschrijven van 
#Out-File -FilePath \\$path\$computername'_'$(get-date -Format yyyy_mm_dd).txt
