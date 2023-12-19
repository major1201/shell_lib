#!/usr/bin/env bash

# A simple database in shell, ref: https://tontinton.com/posts/database-fundementals/
# Set variable DBFILE to specify your database file

_db_set() {
    local db_file=$1
    shift
    echo "$1,$2" >> "${db_file}" && sync -d "${db_file}"
}

_db_get() {
    local db_file=$1
    shift
    grep "^$1," "${db_file}" | sed -e "s/^$1,//" | tail -n 1
}

_db_delete() {
    local db_file=$1
    local key=$2
    sed -ie '/^'"${key}"',/d' "${db_file}"
}

_db_keys() {
    local db_file=$1
    local expr=${2-''}
    awk -F, -v expr="${expr}" '$1 ~ expr {print $1}' "${db_file}" | sort | uniq
}

_db_gc() {
    local db_file=$1
    local key
    awk -F, '{print $1}' "${db_file}" | sort | uniq -c | sort -nr | awk '$1>1 {print $2}' | while read -r key; do
        local val
        val=$(_db_get "${db_file}" "${key}")
        _db_delete "${db_file}" "${key}"
        echo "${key},${val}" >> "${db_file}"
    done
}

db_set() {
    # Usage: db_set db_file key value
    local db_file=$1
    (
        flock 9 && _db_set "$@"
    ) 9> "${db_file}.lock"
}

db_get() {
    # Usage: db_get db_file key, fail if record not exists
    local db_file=$1
    (
        flock -s 9 && _db_get "$@"
    ) 9> "${db_file}.lock"
}

db_delete() {
    # Usage: db_delete db_file key
    local db_file=$1
    (
        flock 9 && _db_delete "$@"
    ) 9> "${db_file}.lock"
}

db_keys() {
    # Usage: db_keys db_file [expr]
    local db_file=$1
    (
        flock -s 9 && _db_keys "$@"
    ) 9> "${db_file}.lock"
}

db_gc() {
    # Usage: db_gc, dedup keys in db_file
    local db_file=$1
    (
        flock 9 && _db_gc "$@"
    ) 9> "${db_file}.lock"
}

with_db_file() {
    # Usage: with_db_file db_file prefix, this will define the wrapper of db_xxx() with db_file
    # e.g. with_db_file myfile my
    #     then you can call my_get, my_set, my_delete, etc.
    local db_file=$1
    local prefix=$2
    [ ! -f "${db_file}" ] && touch "${db_file}"
    for method in set get delete keys gc; do
        eval "${prefix}_${method}() { db_${method} ${db_file} \"\$@\"; }"
    done
}
