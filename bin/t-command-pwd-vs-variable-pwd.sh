#! /bin/bash
#
# Q: How much is POSIX `$PWD` faster than `pwd`?
# A: It is about 7x faster to use `$PWD` to `pwd` (Bash built-in)
# priority: 4
#
#     t1 real 0m0.010s olddir=$PWD ; cd ...do.. ; cd $olddir
#     t2 real 0m0.075s olddir=$(pwd) ; cd ...do.. ; cd $olddir
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
        oldddir=$PWD
        cd /
        # ... do the things
        cd "$olddir"    # or POSIX: cd "$OLDPWD"
    done
}

t2 ()
{
    for i in $(seq $loop_max)
    do
        oldddir=$(pwd)
        cd /
        # ... do the things
        cd "$olddir"
    done
}

t t1
t t2

# End of file
