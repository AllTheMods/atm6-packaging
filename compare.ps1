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
    $slug = [System.IO.Path]::GetFileName($mod.FullName) -replace '[^a-zA-Z-_]+','';
    $matched = $false;
    foreach($oldMod in $oldMods) {
        $oldSlug = [System.IO.Path]::GetFileName($oldMod.FullName) -replace '[^a-zA-Z-_]+','';
        if ($slug -eq $oldSlug) {
            $matched = $true;
            $updated.Add([System.IO.Path]::GetFileName($mod.FullName)) | Out-Null
            $removed.Remove($oldMod)
            break;
        }
    }

    if ($matched -eq $false) {
        $added.Add([System.IO.Path]::GetFileName($mod.FullName)) | Out-Null
    }
}


# render
if ($added.Length -gt 0) {
    Write-Host "### Mod Additions"
    foreach ($name in $added) {
        Write-Host "- $name"
    }    
}
if ($updated.Length -gt 0) {
    Write-Host "### Mod Updates"
    foreach ($name in $updated) {
        Write-Host "- $name"
    }    
}

if ($oldMods.Length -gt 0) {
    Write-Host "### Mod Removals"
    foreach ($mod in $removed) {
        $name = [System.IO.Path]::GetFileName($mod.FullName)
        Write-Host "- $name"
    }    

}


