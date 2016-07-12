#!/bin/sh

keyfile=/etc/glorytun/key

GLORYTUN_BIND_IPS=$(ifconfig ${GLORYTUN_INPUT_DEV} | grep "inet " | awk '{ print $2 }')

if [ -z "${GLORYTUN_HOST}" ]; then
    echo "missing host"
    exit 1
fi
if [ -z "${GLORYTUN_PORT}" ]; then
    echo "missing port"
    exit 1
fi
if [ -z "${GLORYTUN_BIND_IPS}" ]; then
    echo "missing port"
    exit 1
fi

# Default values
: ${GLORYTUN_MTU:=1450}
: ${GLORYTUN_TXQLEN:=1000}
: ${GLORYTUN_DEV:=tun0}
: ${GLORYTUN_IP_LOCAL:=10.0.0.2}
: ${GLORYTUN_IP_PEER:=10.0.0.1}
: ${GLORYTUN_PORT:=5000}

statefile=/run/glorytun.fifo
rm -f "${statefile}"
mkfifo "${statefile}"

trap "pkill -TERM -P $$" TERM
/usr/sbin/glorytun dev ${GLORYTUN_DEV} host ${GLORYTUN_HOST} statefile ${statefile} port ${GLORYTUN_PORT} bind-port ${GLORYTUN_PORT} mtu ${GLORYTUN_MTU} keyfile ${keyfile} bind ${GLORYTUN_BIND_IPS} &
GTPID=$!

initialized() {
    echo "Configuring ${GLORYTUN_DEV}"
    ip addr add ${GLORYTUN_IP_LOCAL} peer ${GLORYTUN_IP_PEER} dev ${GLORYTUN_DEV}
    ip link set ${GLORYTUN_DEV} mtu ${GLORYTUN_MTU}
    ip link set ${GLORYTUN_DEV} txqueuelen ${GLORYTUN_TXQLEN}
    ip link set ${GLORYTUN_DEV} up
    echo "Configuration done"
}

started() {
    echo "mud started"
    echo "setting routes"
    gateway=$(ip route get ${GLORYTUN_HOST} | grep via | awk '{ print $3 }')
    ip route add 0.0.0.0/1 via ${GLORYTUN_IP_LOCAL}
    ip route add 128.0.0.0/1 via ${GLORYTUN_IP_LOCAL}
    ip route add ${GLORYTUN_HOST} via ${gateway} dev ${GLORYTUN_INPUT_DEV}
    echo "routes set"
}

stopped() {
    echo "mud stopped"
    echo "deleting routes"
    ip route del 0.0.0.0/1 via ${GLORYTUN_IP_LOCAL}
    ip route del 128.0.0.0/1 via ${GLORYTUN_IP_LOCAL}
    ip route del ${GLORYTUN_HOST}
    echo "routes deleted"
}

while kill -0 ${GTPID}; do
    read STATE DEV || break
    echo ${STATE} ${DEV}
    case ${STATE} in
    INITIALIZED)
        initialized
        ;;
    STARTED)
        started
        ;;
    STOPPED)
        stopped
        ;;
    esac
done < ${statefile}
