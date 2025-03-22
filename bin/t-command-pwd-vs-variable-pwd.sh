#! /usr/bin/env bash
#
# Q: How much is POSIX `$PWD` and `$OLDPWD` faster than `pwd`?
# A: It is about 7x faster to `pwd`
# priority: 2
#
#     t1 real 0.004 cd ...do.. ; cd $OLDPWD
#     t2 real 0.006 olddir=$PWD ; cd ...do.. ; cd $olddir
#     t3 real 0.011 pushd ; cd ...do.. ; popd
#     t4 real 0.086 olddir=$(pwd) ; cd ...do.. ; cd $olddir
#
# Notes:
#
# Even though `pwd` is a Bash built-in, there
# is still a penalty for calling command
# substitution `$(command)`.

. ./t-lib.sh ; f=$random_file

t1 ()
{
    for i in $(seq $loop_max)
    do
        cd /
        # ... do the things
        cd "$OLDDIR"    # POSIX
    done
}

t2 ()
{
    # Just to see effect of extra variable

    for i in $(seq $loop_max)
    do
        oldddir=$PWD
        cd /
        # ... do the things
        cd "$olddir"
    done
}

t3 ()
{
    for i in $(seq $loop_max)
    do
        pushd . > /dev/null
        cd /
        # ... do the things
        popd > /dev/null
    done
}

t4 ()
{
    for i in $(seq $loop_max)
    do
        oldddir=$(pwd)
        cd /
        # ... do the things
        cd "$olddir"
    done
}

t="\
:t t1
:t t2
:t t3 IsCommandPushd
:t t4
"

[ "$source" ] || RunTests "$t" "$@"

# End of file
