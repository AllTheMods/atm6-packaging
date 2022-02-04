# ATM6 Packager

#### This script requires Powershell 7 (available from https://github.com/PowerShell/PowerShell).

This script expects that you have a Curseforge instance named `All_The_Mods_6`, located in `C:\Games\CurseForge\Minecraft\Instances\`. 

This path can be changed by editing `export.ps1`.

This instance is used for exporting the mod list.

This script clones the config repo, removes unneeded files/folders, and then adds those to a zip. 

The zip version is based on the contents of `config/allthetweaks-common.toml`.

You can add this to your PowerShell profile so that you can call it more easily.

Example (with repo checked out to `~\Documents\Projects\atm6-packaging`)

```powershell
function export {
    Invoke-Expression "$Env:USERPROFILE\Documents\Projects\atm6-packaging\export.ps1"
}
```
