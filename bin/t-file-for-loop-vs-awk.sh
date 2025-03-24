#! /usr/bin/env bash
#
# Q: for-loop file-by-file to awk vs awk handling all the files?
# A: It is about 2-3x faster to do it all in awk
# priority: 7
#
#     t1 real 0m0.213s awk '{...}' <file> <file> ...
#     t1 real 0m0.584s for <files> do ... awk <file> ... done

. ./t-lib.sh ; f=$random_file

tmp=t.tmp

TMP=$(mktemp -d -t test-XXXX)

Setup ()
{
    for i in $(seq 100)
    do
        cp "$f" "$TMP/$f.$i"
    done
}

AtExit ()
{
    rm --recursive --force "$TMP"
}

Awk ()
{
    $AWK '
        END {
            print FILENAME " " $0
        }
    ' "$@"
}

t1 ()
{
    # GNU version has 'ENDFILE'
    $AWK '
        ENDFILE {
            print FILENAME " " FNR " " $0
        }
    ' "$TMP/"* > /dev/null
}

t2 ()
{
    for i in "$TMP"/*
    do
        Awk "$i" > /dev/null
    done
}

t="\
:t t1 IsCommandGnuAwk
:t t2
"

trap AtExit EXIT HUP INT QUIT TERM
Setup

[ "$source" ] || RunTests "$t" "$@"

# End of file
