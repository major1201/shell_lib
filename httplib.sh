#!/usr/bin/env bash

# global vars
CURL_BIN=${CURL_BIN=curl}
HTTPIE_BIN=${HTTPIE_BIN=http}
CALL_MODE=${CALL_MODE=curl}
DEBUG=${DEBUG=true}

# runtime vars
METHOD=GET
LOCATION=https://httpbin.org/get
declare -A HEADERS
unset DATA
declare -a ARGS

resetParams() {
    METHOD=GET
    LOCATION=https://httpbin.org/get
    declare -A HEADERS
    unset DATA
    declare -a ARGS
}

doReq()         { "${CALL_MODE}::${FUNCNAME[0]}"; }
setLocation()   { "${CALL_MODE}::${FUNCNAME[0]}" "$@"; }
get()           { "${CALL_MODE}::${FUNCNAME[0]}" "$@"; }
post()          { "${CALL_MODE}::${FUNCNAME[0]}" "$@"; }
put()           { "${CALL_MODE}::${FUNCNAME[0]}" "$@"; }
patch()         { "${CALL_MODE}::${FUNCNAME[0]}" "$@"; }
delete()        { "${CALL_MODE}::${FUNCNAME[0]}" "$@"; }
setQueryParam() { "${CALL_MODE}::${FUNCNAME[0]}" "$@"; }

# ---------------------------------------------
# Common
# ---------------------------------------------

setHeader() {
    HEADERS+=([$1]="$2")
}

setBasicAuth() {
    user=$1
    password=$2
    setHeader Authorization "Basic $(echo -n "${user}:${password}" | base64)"
}

setBearer() {
    setHeader Authorization "Bearer $1"
}

setData() {
    DATA=$1
}

setDataFile() {
    DATA=$(envsubst < "$1")
}


# ---------------------------------------------
# curl implementation
# ---------------------------------------------

curl::doReq() {
    declare -a CMD

    CMD+=("${CURL_BIN}" --location --request "${METHOD}" "${LOCATION}")
    for key in "${!HEADERS[@]}"; do
        CMD+=(--header "${key}: ${HEADERS[${key}]}")
    done
    if [[ -n ${DATA+x} ]]; then
        CMD+=(--data "${DATA}")
    fi
    CMD+=("${ARGS[@]}")

    ${DEBUG} && errecho "${CMD[@]@Q}"
    "${CMD[@]}"
}

curl::setLocation() {
    LOCATION=$1
}

curl::get() {
    METHOD=GET
    curl::setLocation "$1"
}
curl::post() {
    METHOD=POST
    curl::setLocation "$1"
}
curl::put() {
    METHOD=PUT
    curl::setLocation "$1"
}
curl::patch() {
    METHOD=PATCH
    curl::setLocation "$1"
}
curl::delete() {
    METHOD=DELETE
    curl::setLocation "$1"
}

curl::setQueryParam() {
    ARGS+=(--data-urlencode "$1=$2")
}


# ---------------------------------------------
# httpie implementation
# ---------------------------------------------

httpie::doReq() {
    declare -a CMD
    CMD+=("${HTTPIE_BIN}" --ignore-stdin "${METHOD}" "${LOCATION}")
    for key in "${!HEADERS[@]}"; do
        CMD+=("${key}:${HEADERS[${key}]}")
    done
    if [[ -n ${DATA+x} ]]; then
        CMD+=(--raw "${DATA}")
    fi
    CMD+=("${ARGS[@]}")

    ${DEBUG} && errecho "${CMD[@]@Q}"
    "${CMD[@]}"
}

httpie::setLocation() {
    LOCATION=$1
}

httpie::get() {
    METHOD=GET
    httpie::setLocation "$1"
}
httpie::post() {
    METHOD=POST
    httpie::setLocation "$1"
}
httpie::put() {
    METHOD=PUT
    httpie::setLocation "$1"
}
httpie::patch() {
    METHOD=PATCH
    httpie::setLocation "$1"
}
httpie::delete() {
    METHOD=DELETE
    httpie::setLocation "$1"
}

httpie::setQueryParam() {
    ARGS+=("$1==$2")
}

# ---------------------------------------------
# Runtime
# ---------------------------------------------
run() {
    case "${1-""}" in
    -h|"")
        sed -n 's/^##//p' "$0" | column -t -s ':' |  sed -e 's/^/ /'
        ;;
    *)
        preset "$1"
        "$1"
        shift
        ARGS+=("$@")
        doReq
        ;;
    esac
}

errecho() {
    >&2 echo "${@//$'\n'/}"
}


# ---------------------------------------------
# Examples
# ---------------------------------------------
test::example1() {
    resetParams
    HEADERS+=(["Content-Type"]="application/json")
    ARGS+=(--header "a: b")
    doReq
}
