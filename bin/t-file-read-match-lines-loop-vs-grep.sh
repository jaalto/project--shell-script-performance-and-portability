#! /bin/bash
#
# Q: Will prefilter grep + loop help compared to straight loop?
# A: Yes, using external grep + loop is 2x faster
#
# t1a real    0m0.436s grep before loop
# t1b real    0m0.469s grep before loop (proc)
# t2a real    0m1.105s loop: POSIX case glob
# t2b real    0m1.127s loop: Bash glob [[ ]]
#
# Code:
#
# grep | while ... done             # t1a
# while ... done < <(grep)          # t1b
# while read ... done < file        # t2a
# while read ... done < file        # t2b
#
# Notes:
#
# The practical winner in scripts is the
# '<(proc)' due to variables being visible in the same
# scope. The "grep | while" would create a subshell
# and release the variables after the for-loop.
#
# The file contents are kept in the Kernel cache. If
# the run order "t1a t1b" is reversed to "t1b t1a",
# the FIRST one will always appear to be clocked
# faster, which is probably not the case. They are
# equal due to the cache.

. ./t-lib.sh ; f=$random_file

loop_max=${loop_count:-10}

t1a ()
{
    for i in $(seq $loop_max)
    do
        grep "0" $f | while read -r line
        do
            found=$line
        done
    done
}

t1b ()
{
    for i in $(seq $loop_max)
    do
        while read -r line
        do
            found=$line
        done < <(grep "0" $f)
    done
}

t2a ()
{
    for i in $(seq $loop_max)
    do
        while read -r line
        do
            case "$i" in
                *0*) found=$line
                     ;;
            esac
        done < $f
    done
}

t2b ()
{
    for i in $(seq $loop_max)
    do
        while read -r line
        do
            if [[ $i = *0* ]]; then
                found=$line
            fi
        done < $f
    done
}

t t1a
t t1b
t t2a
t t2b

# End of file
