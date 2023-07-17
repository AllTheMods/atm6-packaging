param([Parameter(Mandatory)][string]$version)
$ErrorActionPreference = "Stop"

$source = "C:\Games\CurseForge\Minecraft\Instances\All_The_Mods_0"
$overridePath = "$PSScriptRoot\overrides"
$manifestPath = "$PSScriptRoot\manifest.json"
$tmpPath = "$PSScriptRoot\tmp"
$modsPath = "$tmpPath\mods"
$batPath = "$tmpPath\startserver.bat"
$shPath = "$tmpPath\startserver.sh"

$ignore = @(
    "297038", # CraftPresence
    "226447", # ResourceLoader
    "232131", # Default Options
    "231275", # Ding
    "268324", # Blur
    "238891", # Dynamic Surroundings
    "222789", # Sound Filters
    "296468", # NoFog
    "282313", # TipTheScales
    "256087", # Notes
    "226406", # Custom Main Menu
    "226188", # Default World Generator
    "238372", # Neat
    "229625", # WAILA-features
    "60089",  # Mouse Tweaks
    "227441", # Fullscreen Windowed
    "235716", # Better Achievements
    "221849", # FogNerf
    "431430", # FlickerFix
    "280294" # FPS Reducer
)

if ( -Not (Test-Path $source)) {
    Write-Host "No CurseForge instance found with the name All_The_Mods_0" -ForegroundColor Red
    exit 1
}

if ( -Not (Test-Path $overridePath)) {
    Write-Host "Cloning configuration repo."
    git clone --branch main --depth 1 --single-branch https://github.com/AllTheMods/ATM-0.git $overridePath
}

Get-ChildItem $overridePath -Exclude "config", "scripts", "resources", "local" | Remove-Item -Recurse

Write-Host "Loading CurseForge manifest..."
Write-HOST "If you have added any mods, you MUST run the game once to update the Curseforge instance JSON.".
$instancePath = "$source\minecraftinstance.json"
$instanceJson = Get-Content $instancePath -raw | ConvertFrom-Json

$forgeVersion = $instanceJson.baseModLoader.forgeVersion;
Write-Host "Manifest uses Forge $forgeVersion."

# start generate server pack

$serverDest = "ATM0-dev-$version-server.zip"
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

Get-Content "$PSScriptRoot\templates\startserver-template-0.bat" -raw | % {$_.replace('@version@', $forgeVersion)} | Set-Content -NoNewline $batPath
Get-Content "$PSScriptRoot\templates\startserver-template-0.sh" -raw | % {$_.replace('@version@', $forgeVersion)} | Set-Content -NoNewline $shPath

$compress = @{
    Path = @(
        "$overridePath/config",
        "$overridePath/scripts",
        "$overridePath/local",
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
$manifestJson = Get-Content "$PSScriptRoot\templates\manifest-template-atm0.json" -raw | ConvertFrom-Json

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

$dest = "ATM0-dev-$version.zip";
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