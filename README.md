# ATM6 Packager

#### This script requires Powershell 7 (included with VS Code).

This script expects that you have a GDLauncher instance named `All_The_Mods_6`. 

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

## Exporting from GDLauncher

1. Run an export, select the directory, and use the default of `%APPDATA%\gdlauncher_next`.
1. Do not change the other values on the first page.
1. On the second page, select the top checkbox to export everything.
1. This should create a zip file at `%APPDATA%\gdlauncher_next\All_The_Mods_6-1.0.zip`