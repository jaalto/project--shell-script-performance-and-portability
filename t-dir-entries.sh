#! /bin/bash
#
# Q: What is the fastest way to get list of directories?
# A: In general, the for-loop. ls(1) is only faster with 100 directories
#
# for 100 directories:
#
# real    0m0.012s ls -ld */
# real    0m0.015s for-loop
#
# for 20 directories:
#
# real    0m0.004s for-loop
# real    0m0.008s ls -d */
#
# TESTING NOTES
#
# Because the OS caches files and directories, you have to
# manually modify this file between the tests:
#
# Manually adjust the number of directories to create in
# Setup(). The default is typical 20 directries.
#
# T1:
# - Comment out test t2
# - Run t1
#
# T2:
# - Comment out t1
# - Run t2

# We don't use ${TMPDIR:-/tmp}
# because that may be on fast tempfs

pwd=$(cd "$(dirname "$0")" && pwd)

Setup ()
{
    tmpdir=$(mktemp --directory --tmpdir="$pwd")

    for i in {0..20}
    do
        [ $i -lt 10 ] && i="0$i"  # 01, 02, ...

        mkdir "$tmpdir/$i"
    done
}

AtExit ()
{
    [ -d "$tmpdir" ] || return 0

    rm -rf "$tmpdir"
}

t1 ()
{
    ls -d -- $tmpdir/*/ > /dev/null
}

t2 ()
{
    list=""

    for dir in $tmpdir/*/
    do
        list="$list ${dir%/}"
    done
}

t ()
{
    echo -n "# $1"
    time $1
    echo
}

trap AtExit EXIT HUP INT QUIT TERM

Setup


t t1
t t2

# End of file
