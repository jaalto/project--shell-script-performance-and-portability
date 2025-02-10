#! /bin/bash
#
# Q: The check if GLOB matches file: stat or Bash compgen?
# A: Bash array+glob/compgen are much faster than stat(1)
#
# t1 real    0m0.026s   Bash compgen GLOB
# t2 real    0m0.028s   Bash array: (GLOB)
# t2 real    0m0.039s   stat -t GLOB
#
# Code:
#
# arr=("file"*)
# compgen -G "file"*
# stat -t "file"*
#
# Notes:
#
# Understandable as stat(1) would do more work by
# opening each file found.

. ./t-lib.sh ; f=$random_file

TMPBASE=${TMPDIR:-/tmp}/${LOGNAME:-$USER}.$$.test.compgen.tmp

AtExit ()
{
    [ "$TMPBASE" ] || return 0

    rm -f "$TMPBASE"*
}

prep ()
{
    touch $TMPBASE.{1..100}
}

t1 ()
{
    i=1
    while [ $i -le $loop_max ]
    do
        i=$((i + 1))
        if compgen -G "$TMPBASE"* > /dev/null; then
            dummy="glob match"
        fi
    done
}

t2 ()
{
    i=1
    while [ $i -le $loop_max ]
    do
        i=$((i + 1))
        arr=("$TMPBASE"*)
        if [ ${#arr[*]} -gt 0 ]; then
            dummy="glob match"
        fi
    done
}

t3 ()
{
    i=1
    while [ $i -le $loop_max ]
    do
        i=$((i + 1))
        if stat -t "$TMPBASE"* > /dev/null; then
            dummy="glob match"
        fi
    done
}

trap AtExit EXIT HUP INT QUIT TERM
prep

t t1
t t2
t t3

# End of file
