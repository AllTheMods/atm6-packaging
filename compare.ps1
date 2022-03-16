param([string]$version)
$ErrorActionPreference = "Stop"

$source = "C:\Games\CurseForge\Minecraft\Instances\All_The_Mods_6\mods\"
$multimc = "C:\Games\MultiMC\instances\ATM6 - $version\minecraft\mods\"


if ( -Not (Test-Path $source)) {
    Write-Host "No CurseForge instance found with the name All_The_Mods_6" -ForegroundColor Red
    exit 1
}

if ( -Not (Test-Path $multimc)) {
    Write-Host "No MultiMC instance found with the name ATM6 - $version" -ForegroundColor Red
    exit 1
}

$newMods = Get-ChildItem $source -Filter "*.jar"
$oldMods = Get-ChildItem $multimc -Filter "*.jar"
$added = [System.Collections.ArrayList]::new();
$updated = [System.Collections.ArrayList]::new();
$removed = [System.Collections.ArrayList]::new($oldMods)

foreach($mod in $newMods) {
    $modFilename = [System.IO.Path]::GetFileName($mod.FullName);
    $slug = $modFilename -replace '[^a-zA-Z-_]+','';
    $matched = $false;
    foreach($oldMod in $oldMods) {
        $oldFilename = [System.IO.Path]::GetFileName($oldMod.FullName)
        $oldSlug = $oldFilename -replace '[^a-zA-Z-_]+','';
        if ($slug -eq $oldSlug) {
            $matched = $true;
            if ($modFilename -ne $oldFilename) {
                $updated.Add($modFilename) | Out-Null
            }
            $removed.Remove($oldMod)
            break;
        }
    }

    if ($matched -eq $false) {
        $added.Add($modFilename) | Out-Null
    }
}


# render
if ($added.Length -gt 0) {
    Write-Output "### Mod Additions"
    foreach ($name in $added) {
        Write-Output "- $name"
    }    
}
if ($updated.Length -gt 0) {
    Write-Output "### Mod Updates"
    foreach ($name in $updated) {
        Write-Output "- $name"
    }    
}

if ($oldMods.Length -gt 0) {
    Write-Output "### Mod Removals"
    foreach ($mod in $removed) {
        $name = [System.IO.Path]::GetFileName($mod.FullName)
        Write-Output "- $name"
    }    

}


