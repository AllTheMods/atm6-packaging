# ATM6 Packager

#### This script requires Powershell 7 (included with VS Code).

This script expects that you have a GDLauncher instance named `All_The_Mods_6`. 

This instance is used to retrieve the `manifest.json` for building the export.

This script clones the config repo, removes unneeded files/folders, and then adds those to a zip. 

The zip version is based on the contents of `config/allthetweaks-common.toml`.

You can add this to your PowerShell profile so that you can call it more easily.

Example (with repo checked out to `~\Documents\Projects\atm6-packaging`)

```powershell
function export {
    Invoke-Expression "$Env:USERPROFILE\Documents\Projects\atm6-packaging\export.ps1"
}
```