#!/bin/sh

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo "This program must be run as root"
    exit 1
fi

RELASE_URL="https://github.com/angt/glorytun/releases/download/"
VERSION="0.0.89-mud"
URL="$RELASE_URL/v$VERSION/glorytun-$VERSION-x86_64.bin"

REPO_BIN_NAME="glorytun-$VERSION"
REPO_VERSIONS="/var/tmp/glorytun"
REPO_VERSION="$REPO_VERSIONS/$REPO_BIN_NAME"
BIN_PATH=/usr/sbin/glorytun-udp

CONFIG_PATH=/etc/glorytun
CONFIG_ENV_PATH="$CONFIG_PATH/env"
CONFIG_KEY_PATH="$CONFIG_PATH/key"

# Create the bin directory
mkdir -p "$REPO_VERSIONS" "$CONFIG_PATH"

# Download the bin
if [ ! -f "$REPO_VERSION" ]; then
	echo "downloading glorytun"
	curl -L "$URL" > "$REPO_VERSION"
	chmod +x "$REPO_VERSION"
	cp "$REPO_VERSION" "$BIN_PATH"
	echo "glorytun installed"
fi

# Let systemd handle the mud* interfaces, ips and routes
echo "Installing systemd network config"
NETWORK_PATH="/etc/systemd/network/30-glorytun.network"
cp glorytun.network "$NETWORK_PATH"
systemctl restart systemd-networkd.service
echo "Done"

# Installing systemd service
echo "Installing systemd service"
cp glorytun.service /etc/systemd/system/glorytun.service
systemctl daemon-reload
echo "Done"


# Installing systemd service
if [ ! -f "$CONFIG_ENV_PATH" ]; then
	echo "Setting up the env"
	cp glorytun.env.sample "$CONFIG_ENV_PATH"
	echo "Please edit $CONFIG_ENV_PATH"
fi
if [ ! -f "$CONFIG_KEY_PATH" ]; then
	echo "Setting up the key"
	touch "$CONFIG_KEY_PATH"
	echo "Please edit $CONFIG_KEY_PATH"
fi
