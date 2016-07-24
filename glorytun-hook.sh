#!/bin/sh
IF=$1
STATUS=$2

if [ "$IF" = "none" ] || [ "$IF" = 'tun0' ]; then
    exit 0
fi

if [ "$STATUS" = "up" ]; then
    echo "starting glorytun"
    systemctl start glorytun
fi

if [ "$STATUS" = "down" ]; then
    echo "stopping glorytun"
    systemctl stop glorytun
fi
