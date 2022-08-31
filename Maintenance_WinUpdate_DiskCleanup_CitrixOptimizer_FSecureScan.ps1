Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force
cd $PSScriptRoot
$Computername = hostname

$update = {

Install-PackageProvider -Name NuGet -Force
Install-Module -Name PSWindowsUpdate -Force
ECHO Y | Powershell Get-WindowsUpdate -AcceptAll -Download -Install -MicrosoftUpdate
write-host "FF wachten, pizza!"
Start-Sleep -Seconds 10

}

$diskcleanup = {

##################################################################################  
# DiskCleanUp  
##################################################################################  
 
## Variables ####   
   
    $objShell = New-Object -ComObject Shell.Application   
    $objFolder = $objShell.Namespace(0xA)   
      
    $temp = get-ChildItem "env:\TEMP"   
    $temp2 = $temp.Value   
      
    $WinTemp = "c:\Windows\Temp\*"   
      
 
  
# Remove temp files located in "C:\Users\USERNAME\AppData\Local\Temp"   
    write-Host "Removing Junk files in $temp2." -ForegroundColor Magenta    
    Remove-Item -Recurse  "$temp2\*" -Force -Verbose   
      
# Empty Recycle Bin # http://demonictalkingskull.com/2010/06/empty-users-recycle-bin-with-powershell-and-gpo/   
    write-Host "Emptying Recycle Bin." -ForegroundColor Cyan    
    $objFolder.items() | %{ remove-item $_.path -Recurse -Confirm:$false}   
      
# Remove Windows Temp Directory    
    write-Host "Removing Junk files in $WinTemp." -ForegroundColor Green   
    Remove-Item -Recurse $WinTemp -Force    
      
#6# Running Disk Clean up Tool    
    write-Host "Finally now , Running Windows disk Clean up Tool" -ForegroundColor Cyan   
    cleanmgr /sagerun:1 | out-Null
    Write-Host "FF wachten, pizza!"
    Start-Sleep -Seconds 10        
    
    write-Host "Clean Up Task Finished !!!"
##### End of the Script ##### ad  
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

Invoke-Command -ScriptBlock $update
Invoke-Command -ScriptBlock $diskcleanup
Invoke-Command -ScriptBlock $componentstorecleanup
Invoke-Command -ScriptBlock $Citrixoptimizer
Invoke-Command -ScriptBlock $FSecure
Out-File -FilePath \\fileserver\Websky\Maintenance_script_Output\$computername'_'$(get-date -Format yyyy_mm_dd).txt