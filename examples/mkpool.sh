#!/usr/bin/env bash

# -------------------------------
# Example for using concurrent pool
# -------------------------------

set -euo pipefail

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

. "${SCRIPTPATH}/../functions.sh"

# Create a pool with 8 slots
mkpool mypool 8

# define my job
do_job() {
    echo doing "$1"
    sleep 1
}

# do my job 100 times
for (( i=0; i < 100; i++ )) do
    go mypool do_job "$i"
done

# wait until all jobs complete
wait
echo "done"
