@echo off
set MAX_RAM=5G
set MIN_RAM=5G
set FORGE_VERSION=@version@
:: To use a specific Java runtime, set an environment variable named ATM7_JAVA to the full path of java.exe.

if not defined ATM7_JAVA (
    set ATM7_JAVA=java
)

set INSTALLER="%~dp0forge-1.18.2-%FORGE_VERSION%-installer.jar"
set FORGE_URL="http://files.minecraftforge.net/maven/net/minecraftforge/forge/1.18.2-%FORGE_VERSION%/forge-1.18.2-%FORGE_VERSION%-installer.jar"

if not exist "%~dp0libraries\" (
    echo Forge not installed, installing now.
    if not exist "%INSTALLER%" (
        echo No Forge installer found, downloading from %FORGE_URL%
        bitsadmin.exe /rawreturn /nowrap /transfer forgeinstaller /download /priority FOREGROUND "%FORGE_URL%" "%INSTALLER%"
    )
    
    echo Running Forge installer.
    "%ATM7_JAVA%" -jar "%INSTALLER%" -installServer
)

:START
"%ATM7_JAVA%" -Xmx%MAX_RAM% -Xms%MIN_RAM% -XX:+UseZGC @libraries/net/minecraftforge/forge/1.18.2-%FORGE_VERSION%/win_args.txt nogui

echo Restarting automatically in 10 seconds (press Ctrl + C to cancel)
timeout /t 10 /nobreak > NUL
goto:START
pause
