$ErrorActionPreference = "Stop"

$source = "C:\Games\CurseForge\Minecraft\Instances\All_The_Mods_0"
$overridePath = "$PSScriptRoot\overrides"

if ( -Not (Test-Path $source)) {
    Write-Host "No CurseForge instance found with the name All_The_Mods_0" -ForegroundColor Red
    exit 1
}

if ( -Not (Test-Path $overridePath)) {
    Write-Host "Cloning configuration repo."
    git clone --branch main --depth 1 --single-branch https://github.com/AllTheMods/ATM-0.git $overridePath
}

Get-ChildItem $overridePath -Exclude "config", "scripts", "resources", "local" | Remove-Item -Recurse

Write-Host "Removing existing configuration."
Get-ChildItem $source -Include "config", "scripts", "resources", "local" -Recurse -Depth 0 | Remove-Item -Recurse

Write-Host "Copying new configuration."
Copy-Item -Recurse -Path "$overridePath/*" -Include "config", "scripts", "resources", "local" -Destination $source 

Write-Host "Cleaning up."
Remove-Item -Recurse -Force -Path $overridePath | Out-Null
Write-Host "Finished."

