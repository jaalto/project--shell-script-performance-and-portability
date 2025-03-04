#! /bin/bash
#
# Q: How much is POSIX $PWD faster than command pwd(1)?
# A: $PWD is about 7x faster considering pwd is bash built-in
#
# t1 real    0m0.010s olddir=$PWD ; cd ...do.. ; cd $olddir
# t2 real    0m0.075s olddir=$(pwd) ; cd ...do.. ; cd $olddir
#
# Notes:
#
# Even though pwd(1) is a Bash built-in, there is still a penalty
# for calling command substitution $(command).

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
