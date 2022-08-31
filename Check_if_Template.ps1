$PSScriptRoot
if ($env:COMPUTERNAME -Like '*000') {.\Maintenance_WinUpdate_DiskCleanup_CitrixOptimizer.ps1}
else {write-host 'niet penis'}