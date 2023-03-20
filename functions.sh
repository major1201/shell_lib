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
