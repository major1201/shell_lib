#!/usr/bin/env bash

errecho() {
    # echo to stderr
    # Usage: errecho "string"

    >&2 echo "${@//$'\n'/}"
}

function isIPv4() {
    # Usage: isIPv4 "string"

    # Set up local variables
    local ip=${1:-1.2.3.4}
    local IFS=.
    local -a a
    read -r -a a <<< "$ip"
    # Start with a regex format test
    [[ $ip =~ ^[0-9]+(\.[0-9]+){3}$ ]] || return 1
    # Test values of quads
    local quad
    for quad in {0..3}; do
        [[ "${a[$quad]}" -gt 255 ]] && return 1
    done
    return 0
}

function identifyIPAddr() {
    # Usage: identifyIPAddr "string"
    #
    # identifyIPAddr "1.1.1.1" => Ipv4
    # identifyIPAddr "fd08::1" => Ipv6
    # identifyIPAddr "1.1.1.1111" => Invalid

    local script=$'
import sys, os
from ipaddress import ip_address, IPv4Address, IPv6Address
try:
    ip = ip_address(sys.stdin.read().strip())
    if type(ip) is IPv4Address:
        print("IPv4")
    elif type(ip) is IPv6Address:
        print("IPv6")
    else:
        print("Unknown")
except:
    print("Invalid")
'
    echo "$1" | python3 -c "${script}"
}

function isIPv6() {
    # Usage: isIPv6 "string"

    local res
    res=$(identifyIPAddr "$1")
    if [[ "${res}" = "IPv6" ]]; then
        return 0
    fi
    return 1
}

function isIPAddr() {
    # Usage: isIPAddr "string"

    local res
    res=$(identifyIPAddr "$1")
    if [[ "${res}" = "IPv4" || "${res}" = "IPv6" ]]; then
        return 0
    fi
    return 1
}

function findFreePort() {
    # Usage: findFreePort "fromPort" "toPort"

    local FROM=$1
    local TO=$2

    comm -23 \
        <(seq "${FROM}" "${TO}") \
        <(ss -ntulp | awk '{print $5}' | awk -F: '{print $NF}' | sort -n | uniq) \
        | shuf | head -n1
}

function macFindFreePort() {
    # Usage: findFreePort "fromPort" "toPort"

    local FROM=$1
    local TO=$2

    comm -23 \
        <(seq "${FROM}" "${TO}") \
        <(sudo lsof -nP -i | grep LISTEN | awk '{print $9}' | awk -F: '{print $NF}' | sort -n | uniq) \
        | shuf | head -n1
}
