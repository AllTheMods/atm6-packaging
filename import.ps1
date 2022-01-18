$ErrorActionPreference = "Stop"

$source = "C:\Games\CurseForge\Minecraft\Instances\All_The_Mods_6"
$overridePath = "$PSScriptRoot\overrides"

if ( -Not (Test-Path $source)) {
    Write-Host "No CurseForge instance found with the name All_The_Mods_6" -ForegroundColor Red
    exit 1
}

if ( -Not (Test-Path $overridePath)) {
    Write-Host "Cloning configuration repo."
    git clone --branch Staging --depth 1 --single-branch https://github.com/AllTheMods/ATM-6.git $overridePath
}

Get-ChildItem $overridePath -Exclude "config", "defaultconfigs", "kubejs", "packmenu" | Remove-Item -Recurse

Write-Host "Removing existing configuration."
Get-ChildItem $source -Include "config", "defaultconfigs", "kubejs", "packmenu" -Recurse -Depth 0 | Remove-Item -Recurse

Write-Host "Copying new configuration."
Copy-Item -Recurse -Path "$overridePath/*" -Include "config", "defaultconfigs", "kubejs", "packmenu" -Destination $source 

Write-Host "Cleaning up."
Remove-Item -Recurse -Force -Path $overridePath | Out-Null
Write-Host "Finished."

