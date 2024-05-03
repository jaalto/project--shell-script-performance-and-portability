#! /bin/bash
#
# Q: What is the fastest way to get newest file in directory
# A: find + awk is almost as fast as "ls -t" (but that would compare both dirs and files)
#
# t1 real    0m0.048s   find + awk
# t2 real    0m0.071s   find + sort + sed
# t3 real    0m0.096s   find + sort + head + cut
# t4 real    0m0.039s   stat
# t5 real    0m0.032s   ls -t
#
# These can't tell files from directories:
#
#   ls -t   sort by time
#   stat

TMPBASE=tmp.$$
DIR=t

AtExit ()
{
    [ "$TMPBASE" ] || return 0

    rm -f "$TMPBASE"*
}

prep ()
{
    mkdir -p $DIR

    # Generate files 1h apart

    for i in {1..100}
    do
        touch --date="-$i hours" $DIR/$TMPBASE.$i || exit $?
    done
}

t1 ()
{
    for i in {1..10}
    do
        find . -maxdepth 1 -type f -printf "%T@ %p\n" |
        awk '
            {
               if ($1 > recent)
               {
                   recent = $1
                   file = $2
               }
            }
            END { print file }
        ' > /dev/null
    done
}

t2 ()
{
    for i in {1..10}
    do
        find $DIR -maxdepth 1 -type f -printf "%T@ %p\n" |
            sort -r | sed -En 's,^.+ ,,; 1p; q' \
            > /dev/null
    done
}

t3 ()
{
    for i in {1..10}
    do
        find $DIR -maxdepth 1 -type f -printf "%T@ %p\n" |
            sort -r | head -1 | cut -d' ' -f2 \
            > /dev/null
    done
}

t4 ()
{
    for i in {1..10}
    do
        stat --format="%Y %n" * |
            sort -r | sed -En 's,^.+ ,,; 1p; q' \
            > /dev/null
    done
}

t5 ()
{
    for i in {1..10}
    do
        ls -t | head --lines=1 \
            > /dev/null
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
t t5

# End of file
