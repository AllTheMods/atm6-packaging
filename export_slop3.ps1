param([string]$version = "")
$ErrorActionPreference = "Stop"

$source = "C:\Games\CurseForge\Minecraft\Instances\slop 3 dev"
$overridePath = "$PSScriptRoot\overrides"
$manifestPath = "$PSScriptRoot\manifest.json"
$serverPath = "$PSScriptRoot\server"
$cachePath = "$PSScriptRoot\cache"
$tmpPath = "$PSScriptRoot\tmp"
$modsPath = "$tmpPath\mods"
$batPath = "$tmpPath\startserver.bat"
$shPath = "$tmpPath\startserver.sh"

$ignore = @(
    "431430", # FlickerFix
    "60089"   # Mouse Tweaks
)


if ( -Not (Test-Path $source)) {
    Write-Host "No CurseForge instance found at '$source'" -ForegroundColor Red
    exit 1
}

New-Item -Path $overridePath -Type Directory -Force | Out-Null
Copy-Item -Path "$source/*" -Include "config", "defaultconfigs", "kubejs", "packmenu" -Destination $overridePath -Recurse -Force

if ($version.Length -eq 0) {
    $tweaks = "$overridePath\config\allthetweaks-common.toml"
    $version = @("major", "minor", "minorrev") | ForEach-Object {
        Select-String -Path $tweaks -Pattern "$_ = (\d+)" | ForEach-Object { $_.matches.Groups[1].value }
    } | Join-String -Separator "."
}

Write-Host "Loading CurseForge manifest..."
Write-HOST "If you have added any mods, you MUST run the game once to update the Curseforge instance JSON.".
$instancePath = "$source\minecraftinstance.json"
$instanceJson = Get-Content $instancePath -raw | ConvertFrom-Json

$forgeVersion = $instanceJson.baseModLoader.forgeVersion;
Write-Host "Manifest uses Forge $forgeVersion."

# start generate Forge server files

$installerUrl = "http://files.minecraftforge.net/maven/net/minecraftforge/forge/1.18.2-${forgeVersion}/forge-1.18.2-${forgeVersion}-installer.jar"
$installerFile = Split-Path -Path $installerUrl -Leaf
$installerPath = "$cachePath\$installerFile"
$installedPath = "$serverPath\forge-${forgeVersion}"

if (-Not (Test-Path -Path $installerPath)) {
    Write-Host "$installerFile not found in cache. Downloading..."
    New-Item -Path $cachePath -Type Directory -Force | Out-Null
    Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath
}

if (-Not (Test-Path -Path $installedPath)) {
    Write-Host "No existing installation for Forge $forgeVersion. Running installer..."
    New-Item -Path $installedPath -Type Directory -Force | Out-Null
    try {
        Push-Location -Path $installedPath
        java -jar $installerPath -installServer
    }
    finally {
        Pop-Location
    }
}

Write-Host "Server installation done."

# end generate Forge server files
# start generate server pack

$serverDest = "SLOP3-dev-$version-server.zip"
Write-Host "Writing server zip to: $serverDest"

if (Test-Path $serverDest) {
    Write-Host "Removing existing export."
    Remove-Item $serverDest
}


New-Item -Path $modsPath  -Type Directory -Force | Out-Null
foreach ($mod in $instanceJson.installedAddons) {
    if (-Not ($ignore -contains $mod.addonID)) {
        $filename = $mod.installedFile.FileNameOnDisk
        Copy-Item -Path "$source\mods\$filename" -Destination "$modsPath\$filename"
    }
}

Copy-Item -Path "$PSScriptRoot\templates\user_jvm_args-slop3.txt" -Destination "$tmpPath\user_jvm_args.txt"
# Get-Content "$PSScriptRoot\templates\startserver-template.bat" -raw | ForEach-Object { $_.replace('@version@', $forgeVersion) } | Set-Content $batPath
# Get-Content "$PSScriptRoot\templates\startserver-template.sh" -raw | ForEach-Object { $_.replace('@version@', $forgeVersion) } | Set-Content $shPath

$compress = @{
    Path             = @(
        "$overridePath/config",
        "$overridePath/defaultconfigs",
        "$overridePath/kubejs",
        "$installedPath/libraries",
        "$installedPath/run.bat",
        "$installedPath/run.sh",
        "$tmpPath/*"
    )
    CompressionLevel = "Fastest"
    DestinationPath  = $serverDest
}

Compress-Archive @compress

Write-Host "Created server archive - cleaning up."
Remove-Item -Recurse -Force -Path $tmpPath

# end generate server pack
# start generate client pack

Write-Host "Generating manifest for version: $version"
$manifestJson = Get-Content "$PSScriptRoot\templates\manifest-template-slop3.json" -raw | ConvertFrom-Json

$manifestJson.minecraft.modLoaders[0].id = "forge-${forgeVersion}"
$manifestJson.version = $version

foreach ($mod in $instanceJson.installedAddons) {
    $manifestJson.files += @{
        projectID = $mod.addonID
        fileID    = $mod.installedFile.id
        required  = $true
    }
}

$manifestJson | ConvertTo-Json -Depth 32 | Set-Content $manifestPath

$dest = "SLOP3-dev-$version.zip";
Write-Host "Writing client zip to: $dest"

if (Test-Path $dest) {
    Write-Host "Removing existing export."
    Remove-Item $dest
}

$compress = @{
    Path             = $manifestPath, $overridePath
    CompressionLevel = "Fastest"
    DestinationPath  = $dest
}

Compress-Archive @compress

Write-Host "Created client archive - cleaning up."

Remove-Item -Recurse -Force -Path $overridePath
Remove-Item -Recurse -Force -Path $manifestPath

# end generate client pack

Write-Host "Finished."