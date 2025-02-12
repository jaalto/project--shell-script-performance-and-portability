#! /bin/bash
#
# Q: process file: will prefilter lines using grep(1) help?
# A: grep(1) + loop is 2x faster than doing filtering in loop
#
# t1a real    0m0.436s grep prefilter before loop
# t1b real    0m0.469s grep prefilter before loop (proc)
# t2a real    0m1.105s loop: POSIX glob match with case...esac
# t2b real    0m1.127s loop: Bash glob match using [[ ]]
#
# Code:
#
# grep | while ... done                      # t1a
# while ... done < <(grep)                   # t1b
# while read ... case..esac ... done < file  # t2a
# while read ... [[ ]] ... done < file       # t2b
#
# Notes:
#
# The practical winner in scripts is the `while read
# do .. done < <(proc)` due to variables being
# visible in the same scope. The "grep | while"
# would create a subshell and release the variables
# after the for-loop.
#
# About the test cases
#
# The file contents read during the test cases are
# probably cached in the Kernel. When the tests are
# executed in the order "t1a t1b," reversing the
# order to "t1b t1a" results in the FIRST test
# consistently appearing to run faster. This is
# likely not an accurate representation of the true
# performance. The apparent equality in performance
# between cases "t1a" and "t2b" is probably due to
# the Kernel's file cache.

[ "${loop_max:+user}" = "user" ] && loop_count=$loop_max

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
