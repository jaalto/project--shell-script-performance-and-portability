#! /usr/bin/env bash
#
# Q: What is the fastest way to check empty directory?
# A: array+glob is faster than built-in `compgen`
# priority: 3
#
#     t1 real 0m0.054s   array+glob
#     t2 real 0m0.104s   compgen
#     t3 real 0m0.304s   ls
#     t3 real 0m0.480s   find | read
#
# Code:
#
#     t1 files=("$dir"/*)
#     t2 compgen -G "$dir"/*
#     ...

. ./t-lib.sh ; f=$random_file

pwd=$(cd "$(dirname "$0")" && pwd)

Setup ()
{
    dir=$(mktemp --directory --tmpdir="$pwd")
}

AtExit ()
{
    [ "$dir" ] || return 0

    rm --force "$dir"
}

# Hide from other shells
# shopt is Bash only
t1 () { : ; } # stub

cat << 'EOF' > t.bash
t1 ()
{
    shopt -s nullglob  # Avoids literal * if directory is empty
    files=()

    for i in $(seq $loop_max)
    do
        files=("$dir"/*)

        if [ "${#files[@]}" = 0 ]; then
            dummy="empty: no glob match"
        fi
    done

    shopt -u nullglob
}
EOF

IsShellBash && . ./t.bash
rm --force t.bash

t2 ()
{
    for i in $(seq $loop_max)
    do
        if ! compgen -G "$dir"/* > /dev/null
        then
            dummy="empty: glob no match"
        fi
    done
}

t3 ()
{
    for i in $(seq $loop_max)
    do
        if [ "$(ls "$dir")" ]; then
            dummy="empty: ls"
        fi
    done
}

t4 ()
{
    # `read` will return error status if there
    # is nothing in input.

    for i in $(seq $loop_max)
    do
        if ! find "$dir" -mindepth 1 -maxdepth 1 -type f |
           read -r
        then
            dummy="empty: find"
        fi
    done
}

t="\
:t t1 IsShellBash
:t t2
:t t3
:t t4
"

trap AtExit EXIT HUP INT QUIT TERM
Setup

[ "$source" ] || RunTests "$t" "$@"

# End of file
