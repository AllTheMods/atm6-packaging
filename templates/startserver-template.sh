#!/bin/sh
MAX_RAM=5G
MIN_RAM=5G
FORGE_VERSION=@version@
# To use a specific Java runtime, set an environment variable named ATM6_JAVA to the full path of java.exe.

INSTALLER="forge-1.16.5-$FORGE_VERSION-installer.jar"
FORGE_URL="http://files.minecraftforge.net/maven/net/minecraftforge/forge/1.16.5-$FORGE_VERSION/forge-1.16.5-$FORGE_VERSION-installer.jar"

if [ ! -f "$0\forge-1.16.5-$FORGE_VERSION.jar" ]; then
    echo "Forge not installed, installing now."
    if [ ! -f "$INSTALLER" ]; then
        echo "No Forge installer found, downloading now."
        which wget >> /dev/null
        if [ $? -eq 0 ]; then
            echo "DEBUG: (wget) Downloading $FORGE_URL"
            wget -O "$INSTALLER" "$FORGE_URL"
        else
            which curl >> /dev/null
            if [ $? -eq 0 ]; then
                echo "DEBUG: (curl) Downloading $FORGE_URL"
                curl -o "$INSTALLER" -L "$FORGE_URL"
            else
                echo "Neither wget or curl were found on your system. Please install one and try again"
            fi
        fi
    fi

    echo "Running Forge installer."
    "${ATM6_JAVA:-java}" -jar "$INSTALLER" -installServer
fi

while true
do
    "${ATM6_JAVA:-java}" -Xmx$MAX_RAM -Xms$MIN_RAM -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=32M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -jar forge-1.16.5-$FORGE_VERSION.jar nogui
    echo "Restarting automatically in 10 seconds (press Ctrl + C to cancel)"
    sleep 10
done
