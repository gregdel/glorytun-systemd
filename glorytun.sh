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

statefile=/run/glorytun.fifo
[ -p "$statefile" ] || mkfifo "$statefile"

# Launch glorytun
/usr/sbin/glorytun dev "$GLORYTUN_DEV" host "$GLORYTUN_HOST" statefile "$statefile" port "$GLORYTUN_PORT" bind-port "$GLORYTUN_PORT" mtu "$GLORYTUN_MTU" keyfile "$keyfile" bind "$GLORYTUN_BIND_IPS" &
GTPID=$!

# Catch the SIGINT / SIGTERM
_stop() {
	kill -TERM $GTPID
	exit 0
}
trap '_stop' TERM INT QUIT

# Remove the statefile on exit
cleanup() {
	echo "starting cleanup"
	echo "deleting FIFO"
	rm -f "$statefile"

	echo "deleting routes"
	ip route del "$GLORYTUN_HOST"
	echo "routes deleted"
	echo "cleanup done"
}
trap 'cleanup' EXIT

while kill -0 "$GTPID"; do
	read -r STATE DEV <"$statefile" || break
	echo "FIFO input: $STATE $DEV"
	case "$STATE" in
		INITIALIZED)
			echo "Configuring ${GLORYTUN_DEV}"
			ip addr add "$GLORTUN_IP_LOCAL" peer "$GLORYTUN_IP_PEER" dev "$GLORYTUN_DEV"
			ip link set "$GLORYTUN_DEV" mtu "$GLORYTUN_MTU"
			ip link set "$GLORYTUN_DEV" txqueuelen "$GLORYTUN_TXQLEN"
			ip link set "$GLORYTUN_DEV" up
			echo "setting routes"
			gateway=$(ip route get "$GLORYTUN_HOST" | grep via | awk '{ print $3 }')
			ip route add 0.0.0.0/1 via "$GLORYTUN_IP_LOCAL"
			ip route add 128.0.0.0/1 via "$GLORYTUN_IP_LOCAL"
			ip route add "$GLORYTUN_HOST" via "$gateway" dev "$GLORYTUN_IF_NAME"
			echo "routes set"
			echo "Configuration done"
			;;
		STARTED)
			echo "mud connected"
			;;
		STOPPED)
			echo "mud disconnected"
			;;
	esac
done
