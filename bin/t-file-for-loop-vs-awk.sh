#! /bin/bash
#
# Q: for-loop file-by-file to awk vs awk handling all the files?
# A: is is at least 2x faster to do it all in awk
#
#     t1 real    0m0.213s awk '{...}' <file> <file> ...
#     t1 real    0m0.584s for <files> do ... awk <file> ... done

. ./t-lib.sh ; f=$random_file

tmp=t.tmp

TMP=$(mktemp -d -t test-XXXX)

Setup ()
{
    for i in {1..100}
    do
        cp "$f" "$TMP/$f.$i"
    done
}

AtExit ()
{
    rm -rf "$TMP"
}

Awk ()
{
    awk '
        END {
            print FILENAME " " $0
        }
    ' "$@"
}

t1 ()
{
    # GNU version has 'ENDFILE'
    awk '
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

trap AtExit EXIT HUP INT QUIT TERM

Setup
t t1
t t2

# End of file
