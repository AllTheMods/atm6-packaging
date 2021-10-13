$ErrorActionPreference = "Stop"

$source = "$env:APPDATA\gdlauncher_next\All_The_Mods_6-1.0.zip"
$overridePath = "$PSScriptRoot\overrides"
$extractPath = "$PSScriptRoot\extract"

if ( -Not (Test-Path $source)) {
    Write-Host "No GDLauncher export found with the name All_The_Mods_6-1.0.zip" -ForegroundColor Red
    exit 1
}

if ( -Not (Test-Path $extractPath)) {
    New-Item -Path $extractPath -ItemType Directory
    Write-Host "Extracting GDLauncher export."
    Expand-Archive -Path $source -DestinationPath $extractPath
}

if ( -Not (Test-Path $overridePath)) {
    Write-Host "Cloning configuration repo."
    git clone --branch Staging --depth 1 --single-branch https://github.com/AllTheMods/ATM-6.git $overridePath
}

Get-ChildItem $overridePath -Exclude "config", "defaultconfigs", "kubejs", "packmenu" | Remove-Item -Recurse

$tweaks = "$overridePath\config\allthetweaks-common.toml"

$version = @("major", "minor", "minorrev") | ForEach-Object {
    Select-String -Path $tweaks -Pattern "$_ = (\d+)" | ForEach-Object {$_.matches.Groups[1].value}
} | Join-String -Separator "."

Write-Host "Updating manifest to version: $version"
$manifestPath = "$extractPath\manifest.json"
$manifestJson = Get-Content $manifestPath -raw | ConvertFrom-Json

$manifestJson.version = $version
$manifestJson.author = "ATM6 Team"
$manifestJson.name = "All the Mods 6"

$manifestJson | ConvertTo-Json -Depth 32 | Set-Content $manifestPath

$dest = "ATM6-dev-$version.zip";
Write-Host "Writing zip to: $dest"

if (Test-Path $dest) {
    Write-Host "Removing existing export."
    Remove-Item $dest
}

$compress = @{
    Path = $manifestPath, "$extractPath\modlist.html", $overridePath
    CompressionLevel = "Fastest"
    DestinationPath = $dest
}

Compress-Archive @compress

Write-Host "Created archive - cleaning up."

Remove-Item -Recurse -Force -Path $overridePath
Remove-Item -Recurse -Force -Path $extractPath

Write-Host "Finished."