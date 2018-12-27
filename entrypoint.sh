#!/bin/bash
set -e

function acquire_host() {

    DOCKER_HOST=""
    DOCKER_RSLVR="none"

    #-- docker 18 - non-linux

    DOCKER_RSLVR="host.docker.internal"
    DOCKER_HOST="$(getent hosts $DOCKER_RSLVR | cut -d' ' -f1)"
    if [ "$DOCKER_HOST" != "" ] ; then return 0 ; fi

    #-- docker 17 - macOS

    DOCKER_RSLVR="docker.for.mac.localhost"
    DOCKER_HOST="$(getent hosts $DOCKER_RSLVR | cut -d' ' -f1)"
    if [ "$DOCKER_HOST" != "" ] ; then return 0 ; fi

    DOCKER_RSLVR="docker.for.mac.host.internal"
    DOCKER_HOST="$(getent hosts $DOCKER_RSLVR | cut -d' ' -f1)"
    if [ "$DOCKER_HOST" != "" ] ; then return 0 ; fi

    #-- docker 17 - windows

    DOCKER_RSLVR="docker.for.win.localhost"
    DOCKER_HOST="$(getent hosts $DOCKER_RSLVR | cut -d' ' -f1)"
    if [ "$DOCKER_HOST" != "" ] ; then return 0 ; fi

    #-- docker XX - linux

    DOCKER_RSLVR="docker.bridge.gateway"
    DOCKER_HOST="$(ip -4 route show default | cut -d' ' -f3)"
    if [ "$DOCKER_HOST" != "" ] ; then return 0 ; fi

}

acquire_host

echo "\--> Resolved docker host routable ip as : $DOCKER_HOST ($DOCKER_RSLVR)"

FORWARDING_PORTS=${PORTS:-'0:65535'}

iptables -t nat -I PREROUTING -p tcp --match multiport --dports "$FORWARDING_PORTS" -j DNAT --to-destination $DOCKER_HOST
iptables -t nat -I POSTROUTING -j MASQUERADE

trap "exit 0;" TERM INT

SLEEP_FOR=${WAIT_FOR:-20}

while true ; do sleep $SLEEP_FOR ; done
