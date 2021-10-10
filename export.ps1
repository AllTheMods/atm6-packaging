$ErrorActionPreference = "Stop"

$manifest = "$env:APPDATA\gdlauncher_next\instances\All_The_Mods_6\manifest.json"

if ( -Not (Test-Path $manifest)) {
    Write-Host "No GDLauncher instance found with the name All_The_Mods_6" -ForegroundColor Red
    exit 1
}

Copy-Item -Path $manifest  -Destination $PSScriptRoot\manifest.json

if ( -Not (Test-Path overrides)) {
    git clone --branch Staging --depth 1 --single-branch https://github.com/AllTheMods/ATM-6.git $PSScriptRoot\overrides
}

Get-ChildItem $PSScriptRoot\overrides -Exclude "config", "defaultconfigs", "kubejs", "packmenu" | Remove-Item -Recurse

$tweaks = "$PSScriptRoot\overrides\config\allthetweaks-common.toml"

$version = @("major", "minor", "minorrev") | ForEach-Object {
    Select-String -Path $tweaks -Pattern "$_ = (\d+)" | ForEach-Object {$_.matches.Groups[1].value}
} | Join-String -Separator "."

$dest = "ATM6-dev-$version.zip";
Write-Host "Writing zip to: $dest"

if (Test-Path $dest) {
    Write-Host "Removing existing export."
    Remove-Item $dest
}

$compress = @{
    Path = "$PSScriptRoot\manifest.json", "$PSScriptRoot\overrides"
    CompressionLevel = "Fastest"
    DestinationPath = $dest
}

Compress-Archive @compress

Write-Host "Created archive - cleaning up."

Remove-Item -Recurse -Force -Path $PSScriptRoot\overrides
Remove-Item $PSScriptRoot\manifest.json

Write-Host "Finished."