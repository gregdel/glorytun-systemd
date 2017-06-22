#!/bin/sh

keyfile=/etc/glorytun/key

# Get the name of the interface with the default route
GLORYTUN_IF_NAME=$(ip route | grep default | awk '{ print $5 }')

# Get the IP on this interface
GLORYTUN_BIND_IPS=$(ifconfig "$GLORYTUN_IF_NAME" | grep "inet " | awk '{ print $2 }')

if [ -z "$GLORYTUN_HOST" ]; then
	echo "missing host"
	exit 1
fi
if [ -z "$GLORYTUN_PORT" ]; then
	echo "missing port"
	exit 1
fi

# Default values
: "${GLORYTUN_MTU:=1450}"
: "${GLORYTUN_TXQLEN:=1000}"
: "${GLORYTUN_DEV:=tun0}"
: "${GLORYTUN_IP_LOCAL:=10.0.0.2}"
: "${GLORYTUN_IP_PEER:=10.0.0.1}"
: "${GLORYTUN_PORT:=5000}"

echo "Creating $GLORYTUN_DEV"
ip tuntap add dev "$GLORYTUN_DEV" mode tun 2>/dev/null
ip addr add "$GLORYTUN_IP_LOCAL" peer "$GLORYTUN_IP_PEER" dev "$GLORYTUN_DEV" 2>/dev/null
ip link set "$GLORYTUN_DEV" txqueuelen "$GLORYTUN_TXQLEN" up 2>/dev/null
echo "Done"

echo "Connecting to $GLORYTUN_HOST on port $GLORYTUN_PORT, binding on $GLORYTUN_BIND_IPS"
# Launch glorytun
glorytun-udp \
	keyfile "$keyfile" \
	host "$GLORYTUN_HOST" \
	port "$GLORYTUN_PORT" \
	dev "$GLORYTUN_DEV" \
	bind-port "$GLORYTUN_PORT" \
	mtu "$GLORYTUN_MTU" \
	bind "$GLORYTUN_BIND_IPS" \
	v4only
