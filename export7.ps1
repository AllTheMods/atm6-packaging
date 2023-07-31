param([string]$version = "")
$ErrorActionPreference = "Stop"

$source = "C:\Games\CurseForge\Minecraft\Instances\All_The_Mods_7"
$overridePath = "$PSScriptRoot\overrides"
$manifestPath = "$PSScriptRoot\manifest.json"
$tmpPath = "$PSScriptRoot\tmp"
$modsPath = "$tmpPath\mods"
$batPath = "$tmpPath\startserver.bat"
$shPath = "$tmpPath\startserver.sh"

$ignore = @(
    "263420", # Xaero's Minimap
    "317780", # Xaero's World Map
    "232131", # Default Options
    "231275", # Ding
    "367706", # FancyMenu
    "261725", # ItemZoom
    "243863", # No Potion Shift
    "305373", # Reload Audio Driver
    "325492", # Light Overlay
    "296468", # NoFog
    "308240", # Cherished Worlds
    "362791", # Cull Particles
    "291788", # Server Tab Info
    "326950", # Screenshot to Clipboard
    "237701", # ReAuth
    "391382", # MoreOverlays
    "358191", # PackMenu
    "271740", # Toast Control
    "428199", # Out Of Sight
    "431430", # FlickerFix
    "240630", # Just Enough Resources
    "532127", # Legendary Tooltips
    "499826", # Advancement Plaques
    "60089" , # Mouse Tweaks
    "446253", # Better Biome Blend
    "502561", # Equipment Compare
    "448233", # Entity Culling
    "401648", # BetterF3
    "583228", # SimpleBackups
    "630188", # Dynamic Surroundings Resurrected
    "557796", # Effective (Forge)
    "280294" # FPS Reducer
)

if ( -Not (Test-Path $source)) {
    Write-Host "No CurseForge instance found with the name All_The_Mods_7" -ForegroundColor Red
    exit 1
}

if ( -Not (Test-Path $overridePath)) {
    Write-Host "Cloning configuration repo."
    git clone --branch Staging --depth 1 --single-branch https://github.com/AllTheMods/ATM-7.git $overridePath
}

Get-ChildItem $overridePath -Exclude "config", "defaultconfigs", "kubejs", "packmenu" | Remove-Item -Recurse

if ($version.Length -eq 0) {
    $tweaks = "$overridePath\config\allthetweaks-common.toml"
    $version = @("major", "minor", "minorrev") | ForEach-Object {
        Select-String -Path $tweaks -Pattern "$_ = (\d+)" | ForEach-Object {$_.matches.Groups[1].value}
    } | Join-String -Separator "."    
}

Write-Host "Loading CurseForge manifest..."
Write-HOST "If you have added any mods, you MUST run the game once to update the Curseforge instance JSON.".
$instancePath = "$source\minecraftinstance.json"
$instanceJson = Get-Content $instancePath -raw | ConvertFrom-Json

$forgeVersion = $instanceJson.baseModLoader.forgeVersion;
Write-Host "Manifest uses Forge $forgeVersion."

# start generate server pack

$serverDest = "ATM7-dev-$version-server.zip"
Write-Host "Writing server zip to: $serverDest"

if (Test-Path $serverDest) {
    Write-Host "Removing existing export."
    Remove-Item $serverDest
}


New-Item -Path $modsPath  -Type Directory -Force | Out-Null
foreach($mod in $instanceJson.installedAddons) {
    if (-Not ($ignore -contains $mod.addonID)) {
        $filename = $mod.installedFile.FileNameOnDisk
        Copy-Item -LiteralPath "$source\mods\$filename" -Destination "$modsPath\$filename"
    }
}

Copy-Item -Path "$PSScriptRoot\templates\user_jvm_args-atm7.txt" -Destination "$tmpPath\user_jvm_args.txt"
Get-Content "$PSScriptRoot\templates\startserver-template-18.bat" -raw | % {$_.replace('@version@', $forgeVersion)} | Set-Content -NoNewline $batPath
Get-Content "$PSScriptRoot\templates\startserver-template-18.sh" -raw | % {$_.replace('@version@', $forgeVersion)} | Set-Content -NoNewline $shPath

$compress = @{
    Path = @(
        "$overridePath/config",
        "$overridePath/defaultconfigs",
        "$overridePath/kubejs",
        "$tmpPath/*"
    )
    CompressionLevel = "Fastest"
    DestinationPath = $serverDest
}
Compress-Archive @compress

Write-Host "Created server archive - cleaning up."
Remove-Item -Recurse -Force -Path $tmpPath

# end generate server pack
# start generate client pack

Write-Host "Generating manifest for version: $version"
$manifestJson = Get-Content "$PSScriptRoot\templates\manifest-template-atm7.json" -raw | ConvertFrom-Json

$manifestJson.minecraft.modLoaders[0].id = "forge-${forgeVersion}"
$manifestJson.version = $version

foreach($mod in $instanceJson.installedAddons) {
    $manifestJson.files += @{
        projectID = $mod.addonID
        fileID = $mod.installedFile.id
        required = $true
    }
}

$manifestJson | ConvertTo-Json -Depth 32 | Set-Content $manifestPath

$dest = "ATM7-dev-$version.zip";
Write-Host "Writing client zip to: $dest"

if (Test-Path $dest) {
    Write-Host "Removing existing export."
    Remove-Item $dest
}

$compress = @{
    Path = $manifestPath, $overridePath
    CompressionLevel = "Fastest"
    DestinationPath = $dest
}

Compress-Archive @compress

Write-Host "Created client archive - cleaning up."

Remove-Item -Recurse -Force -Path $overridePath
Remove-Item -Recurse -Force -Path $manifestPath

# end generate client pack

Write-Host "Finished."