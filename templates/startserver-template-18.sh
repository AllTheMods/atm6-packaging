#!/bin/sh
MAX_RAM=5G
MIN_RAM=5G
FORGE_VERSION=@version@
# To use a specific Java runtime, set an environment variable named ATM7_JAVA to the full path of java.exe.

INSTALLER="forge-1.18.2-$FORGE_VERSION-installer.jar"
FORGE_URL="http://files.minecraftforge.net/maven/net/minecraftforge/forge/1.18.2-$FORGE_VERSION/forge-1.18.2-$FORGE_VERSION-installer.jar"

pause() {
    printf "%s\n" "Press enter to continue..."
    read ans
}

if ! command -v "${ATM7_JAVA:-java}" >/dev/null 2>&1; then
    echo "Minecraft 1.18 requires Java 17 - Java not found"
    pause
    exit 1
fi

JAVA_VERSION=$("${ATM7_JAVA:-java}" -fullversion 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f1)
if [ ! $JAVA_VERSION = "17" ]; then
    echo "Minecraft 1.18 requires Java 17 - found Java $JAVA_VERSION"
    pause
    exit 1
fi

if [ ! -d "$0/libraries/" ]; then
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
    "${ATM7_JAVA:-java}" -jar "$INSTALLER" -installServer
fi

while true
do
    "${ATM7_JAVA:-java}" -Xmx$MAX_RAM -Xms$MIN_RAM -XX:+UseZGC @libraries/net/minecraftforge/forge/1.18.2-$FORGE_VERSION/unix_args.txt nogui
    echo "Restarting automatically in 10 seconds (press Ctrl + C to cancel)"
    sleep 10
done
