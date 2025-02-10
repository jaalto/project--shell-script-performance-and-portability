#! /bin/bash
#
# Q: Which one is faster to check if GLOB matches: stat or Bash compgen?
# A: Bash built-in compgen is much faster
#
# t1 real    0m0.002s   Bash compgen GLOB
# t2 real    0m0.042s   stat -t GLOB

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
    for i in {1..10}
    do
        if compgen -G "$TMPBASE"* > /dev/null; then
            dummy="glob match"
        fi
    done
}

t2 ()
{
    for i in {1..10}
    do
        if stat -t "$TMPBASE"* > /dev/null; then
            dummy="glob match"
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

# End of file
