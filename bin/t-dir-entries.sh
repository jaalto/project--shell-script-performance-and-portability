#! /usr/bin/env bash
#
# Q: Fastest to get list of dirs: loop vs `compgen` vs `ls -d`
# A: No notable differences.`ls` is good enough.
# priority: 1
#
# For 20 directories:
#
#     t1 real 0m0.003s compgen -G */
#     t2 real 0m0.001s for-loop
#     t3 real 0m0.004s ls -d */
#     t4 real 0m0.007s find . -maxdepth 1-type d
#
# For 100 directories:
#
#     t1 real 0m0.012s compgen -G */
#     t2 real 0m0.015s for-loop
#     t3 real 0m0.010s ls -d */
#     t4 real 0m0.011s find . -maxdepth 1 -type d
#
# Notes:
#
# Because the OS caches files and directories, run
# tests manually:
#
#     max_dirs=20 ./t-dir-entries.sh t1
#     max_dirs=20 ./t-dir-entries.sh t2
#     max_dirs=20 ./t-dir-entries.sh t3
#     max_dirs=20 ./t-dir-entries.sh t4

# We don't use ${TMPDIR:-/tmp}
# because that may be on fast tempfs

. ./t-lib.sh ; f=$random_file

pwd=$(cd "$(dirname "$0")" && pwd)
max_dirs=${max_dirs:-20}

Setup ()
{
    # GLOBAL: tmpdir, see AtExit
    tmpdir=$(mktemp --directory --tmpdir="$pwd")

    IFS='
 '

    for i in $(seq $max_dirs)
    do
        i=$i
        item=$(printf "%03d" $i)
        mkdir "$tmpdir/$item"
    done

    unset i item
}

AtExit ()
{
    [ -d "$tmpdir" ] || return 0

    rm --recursive --force "$tmpdir"
}

# Hide from other shells
t1 () { : ; } # stub

cat << 'EOF' > t.bash
t1 ()
{
    cd $tmpdir
    compgen -A directory > /dev/null
    cd $OLDDIR
}
EOF

IsShellBash && . ./t.bash
rm --force t.bash

t2 ()
{
    cd $tmpdir
    list=""

    for dir in $tmpdir/*/
    do
        list="$list $dir"
    done

    cd $OLDDIR
}


t3 ()
{
    cd $tmpdir
    ls -d -- $tmpdir/*/ > /dev/null
    cd $OLDDIR
}

t4 ()
{
    cd $tmpdir
    find . -maxdepth 1 -type d > /dev/null
    cd $OLDDIR
}



t="\
:t t1 IsShellBash
:t t2
:t t3
:t t4
"

SetupTrapAtExit AtExit
Setup

[ "$source" ] || RunTests "$t" "$@"

# End of file
