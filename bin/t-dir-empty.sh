#! /bin/bash
#
# Q: What is the fastest way to check empty directory?
# A: array+glob is faster than built-in compgen
#
# t1 real    0m0.054s   array+glob
# t2 real    0m0.104s   compgen
# t3 real    0m0.304s   ls (out of curiosity)
# t3 real    0m0.480s   find|read

. ./t-lib.sh ; f=$random_file

TMPBASE=${TMPDIR:-/tmp}/${LOGNAME:-$USER}.$$.test.compgen.tmp

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

t1 ()
{
    shopt -s nullglob  # Avoids literal * if directory is empty
    local -a files

    i=1
    while [ $i -le $loop_max ]
    do
        files=("$dir"/*)

        if [ "${#files[@]}" = 0 ]; then
            dummy="empty: no glob match"
        fi
    done

    shopt -u nullglob
}

t2 ()
{
    i=1
    while [ $i -le $loop_max ]
    do
        if ! compgen -G "$dir"/* > /dev/null
        then
            dummy="empty: glob no match"
        fi
    done
}

t3 ()
{
    # Do not use. Just out of curiosity.

    i=1
    while [ $i -le $loop_max ]
    do
        if [ "$(ls "$dir")" ]; then
            dummy="empty: ls"
        fi
    done
}

t4 ()
{
    # Just out of curiosity.

    i=1
    while [ $i -le $loop_max ]
    do
        if ! find "$dir" -mindepth 1 -maxdepth 1 -type f |
           read -r
        then
            dummy="empty: find"
        fi
    done
}

trap AtExit EXIT HUP INT QUIT TERM
Setup

t t1
t t2
t t3
t t4

# End of file
