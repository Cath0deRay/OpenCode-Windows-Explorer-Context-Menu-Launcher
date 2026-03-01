<# 
Install OpenCode context menu entries (folder + folder background).
Per-user by default (HKCU\Software\Classes).

Usage:
  .\Install-OpenCodeExplorerContextMenuLauncher.ps1
  .\Install-OpenCodeExplorerContextMenuLauncher.ps1 -AllUsers   (requires admin)
  .\Install-OpenCodeExplorerContextMenuLauncher.ps1 -Uninstall
#>

param(
	[String]$MenuText = 'OpenCode here',
    [Switch]$Uninstall,
    [Switch]$AllUsers
)

if($AllUsers){
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        throw "AllUsers requires an elevated PowerShell session (Run as Administrator)."
    }
}

$iconFile = if(Test-Path $env:LOCALAPPDATA\OpenCode\OpenCode.exe){
	 "$env:LOCALAPPDATA\OpenCode\OpenCode.exe"
}
else{
	"$env:SystemRoot\System32\cmd.exe"
}

$registryPath = if($AllUsers){ 'HKLM:\Software\Classes' } else { 'HKCU:\Software\Classes' }

$keyFolder = Join-Path -Path $registryPath -ChildPath 'Directory\shell\OpenCodeCmd'
$keyBack = Join-Path -Path $registryPath -ChildPath 'Directory\Background\shell\OpenCodeCmd'

if($Uninstall){
	Remove-Item -Path $keyFolder -Recurse -Force
	Remove-Item -Path $keyBack -Recurse -Force
    Write-Host ("Removed context menu entries from {0}." -f $registryPath)
}
else{
	& {
	New-Item -Path $keyFolder -Force
	New-ItemProperty -Path $keyFolder -Name '(Default)' -Value $MenuText -PropertyType String -Force
	New-ItemProperty -Path $keyFolder -Name 'Icon' -Value $iconFile -PropertyType String -Force
	$folderCmdKey = Join-Path -Path $keyFolder -ChildPath 'command'
	New-Item -Path $folderCmdKey -Force
	$FolderCommand = 'cmd.exe /k "cd /d "%1" && call opencode"'
	New-ItemProperty -Path $folderCmdKey -Name '(Default)' -Value $FolderCommand -PropertyType String -Force

	New-Item -Path $keyBack -Force
	New-ItemProperty -Path $keyBack -Name '(Default)' -Value $MenuText -PropertyType String -Force
	New-ItemProperty -Path $keyBack -Name 'Icon' -Value $iconFile -PropertyType String -Force
	$backCmdKey = Join-Path -Path $keyBack -ChildPath 'command'
	New-Item -Path $backCmdKey -Force
	$backCommand = 'cmd.exe /k "cd /d "%V" && call opencode"'
	New-ItemProperty -Path $backCmdKey -Name '(Default)' -Value $backCommand -PropertyType String -Force
	} | Out-Null
}






