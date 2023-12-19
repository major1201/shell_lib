#!/usr/bin/env bash

set -euo pipefail

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

source "${SCRIPTPATH}/functions.sh"
source "${SCRIPTPATH}/pure_bash.sh"
source "${SCRIPTPATH}/simple_db.sh"

# ----- CUSTOM SCRIPTS -----
isIPv4 "127.0.0.1"
