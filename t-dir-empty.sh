#! /bin/bash
#
# Q: Fastest way to check empty directory?
# A: array+glob is faster than built-in compgen
#
# t1 real    0m0.054s   array+glob
# t2 real    0m0.104s   compgen
# t3 real    0m0.304s   ls (out of curiosity)
# t3 real    0m0.480s   find|read

TMPBASE=${TMPDIR:-/tmp}/${LOGNAME:-$USER}.$$.test.compgen.tmp

dir="t.tmp"

mkdir -p "$dir"

AtExit ()
{
    [ "$dir" ] || return 0

    rm -rf "$dir"
}

t1 ()
{
    shopt -s nullglob  # Avoids literal * if directory is empty
    local -a files

    for i in {1..100}
    do
        files=( "$dir"/* )

        if [ "${#files[@]}" = 0 ]; then
            dummy="empty: no glob match"
        fi
    done

    shopt -u nullglob
}

t2 ()
{
    for i in {1..100}
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

    for i in {1..100}
    do
        if [ "$(ls "$dir")" ]; then
            dummy="empty: ls"
        fi
    done
}

t4 ()
{
    # Do not use. Just out of curiosity.

    for i in {1..100}
    do
        if ! find "$dir" -mindepth 1 -maxdepth 1 -type f |
           read -r
        then
            dummy="empty: find"
        fi
    done
}


t ()
{
    echo -n "# $1"
    time $1
    echo
}

trap AtExit EXIT HUP INT QUIT TERM
prep

t t1
t t2
t t3
t t4

# End of file
