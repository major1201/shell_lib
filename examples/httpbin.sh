#!/usr/bin/env bash

# -------------------------------
# Example for using httplib.sh
# -------------------------------

set -euo pipefail

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

. "${SCRIPTPATH}/../httplib.sh"

BASE_URL="https://httpbin.org"

preset() {
    resetParams
}

## Document: https://httpbin.org/

## httpGet: get
httpGet() {
    get "${BASE_URL}/get"
}

## httpPost: post
httpPost() {
    post "${BASE_URL}/post"
    setData $'{"name": "httpbin"}'
}

## httpPut: put
httpPut() {
    put "${BASE_URL}/put"
    setData $'{"name": "httpbin"}'
}

## httpPatch: patch
httpPatch() {
    patch "${BASE_URL}/patch"
    setData $'{"name": "httpbin"}'
}

## httpDelete: delete
httpDelete() {
    delete "${BASE_URL}/delete"
    setData $'{"name": "httpbin"}'
}

## authBasic: basic auth
authBasic() {
    setBasicAuth admin pwd
    get "${BASE_URL}/basic-auth/admin/pwd"
}

## authBearer: bearer auth
authBearer() {
    setBearer mytoken
    get "${BASE_URL}/bearer"
}

run "$@"
