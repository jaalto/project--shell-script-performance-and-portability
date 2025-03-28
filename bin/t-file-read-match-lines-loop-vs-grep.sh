#! /usr/bin/env bash
#
# Q: Howabout using `grep` to prefilter before loop?
# A: It is about 2x faster to use `grep` than doing all in a loop
# priority: 7
#
#     t1a real 0m4.420s  grep prefilter before loop
#     t1b real 0m5.050s  grep prefilter before loop (process substitution)
#     t2a real 0m11.330s loop: POSIX glob match with case...esac
#     t2b real 0m11.300s loop: Bash glob match using [[ ]]
#
# Code:
#
#     t1a grep | while ... done
#     t1b while ... done < <(grep)
#     t2a while read ... case..esac ... done < file
#     t2b while read ... [[ ]] ... done < file
#
# Notes:
#
# In Bash, the preferred one is the
# `while read do .. done < <(proc)` due to
# variables being visible in the same scope.
#
# The `grep | while` would create a subshell
# and release the variables after the
# for-loop.
#
# _About the test cases_
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

. ./t-lib.sh ; f=$random_file

loop_max=${loop_max:-${loop_count:-10}}

t1a ()
{
    for i in $(seq $loop_max)
    do
        grep "0" $f |
        while read -r line
        do
            found=$line
        done
    done
}

# Hide from other shells
t1b () { : ; } # stub

cat << 'EOF' > t.bash
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
EOF

IsFeatureProcessSubstitution && . ./t.bash
rm --force t.bash

t2a ()
{
    for i in $(seq $loop_max)
    do
        while read -r line
        do
            case $i in
                *0*) found=$line
                     ;;
            esac
        done < $f
    done
}

# Hide from other shells
t2b () { : ; } # stub

cat << 'EOF' > t.bash
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
EOF
IsFeatureMatchGlob && . ./t.bash
rm --force t.bash

t="\
:t t1a
:t t1b IsFeatureProcessSubstitution
:t t2a
:t t2b IsFeatureMatchGlob
"

[ "$source" ] || RunTests "$t" "$@"

# End of file
