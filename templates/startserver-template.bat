@echo off
set MAX_RAM=5G
set MIN_RAM=5G
set FORGE_VERSION=@version@
:: To use a specific Java runtime, set an environment variable named ATM6_JAVA to the full path of java.exe.
:: To disable automatic restarts, set an environment variable named ATM6_RESTART to false.
:: To install the pack without starting the server, set an environment variable named ATM6_INSTALL_ONLY to true.
set MIRROR=https://maven.allthehosting.com/releases/
set INSTALLER="%~dp0forge-1.16.5-%FORGE_VERSION%-installer.jar"
set FORGE_URL="%MIRROR%net/minecraftforge/forge/1.16.5-%FORGE_VERSION%/forge-1.16.5-%FORGE_VERSION%-installer.jar"

:JAVA
if not defined ATM6_JAVA (
    set ATM6_JAVA=java
)

:FORGE
setlocal
cd /D "%~dp0"
if not exist "libraries" (
    echo Forge not installed, installing now.
    if not exist %INSTALLER% (
        echo No Forge installer found, downloading from %FORGE_URL%
        bitsadmin.exe /rawreturn /nowrap /transfer forgeinstaller /download /priority FOREGROUND %FORGE_URL% %INSTALLER%
    )
    
    echo Running Forge installer.
    "%ATM6_JAVA%" -jar %INSTALLER% -installServer -mirror %MIRROR%
)

if not exist "server.properties" (
    (
        echo allow-flight=true
        echo motd=All the Mods 6
        echo max-tick-time=180000
    )> "server.properties"
)

if "%ATM6_INSTALL_ONLY%" == "true" (
    echo INSTALL_ONLY: complete
    goto:EOF
)

:START
"%ATM6_JAVA%" -Xmx%MAX_RAM% -Xms%MIN_RAM% -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=32M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -jar forge-1.16.5-%FORGE_VERSION%.jar nogui

if "%ATM6_RESTART%" == "false" ( 
    goto:EOF 
)

echo Restarting automatically in 10 seconds (press Ctrl + C to cancel)
timeout /t 10 /nobreak > NUL
goto:START
pause
