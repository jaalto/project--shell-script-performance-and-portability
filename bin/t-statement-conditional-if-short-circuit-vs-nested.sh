#! /usr/bin/env bash
#
# Q: if test && test vs nested if statements
# A: No difference whatsoever.
# priority: 0
#
#     t1        real 0m0.010s case with default
#     t2        real 0m0.008s case without default
#
# Notes:
#
# As all would guess, there should not be any
# difference. Out of curiosity the test was run
# with 10 000 loop iterations just to stress out
# the shell interepreters.
#
#      ./run.sh --shell dash,ksh,bash --loop-max 10000 ./t-statement-conditional-if-short-circuit-vs-nested.sh
#
#      Run shell: dash
#      t1       real 0.051  user 0.053  sys 0.000
#      t2       real 0.043  user 0.044  sys 0.000
#      Run shell: ksh
#      t1       real 0.017  user 0.017  sys 0.000
#      t2       real 0.021  user 0.019  sys 0.001
#      Run shell: bash
#      t1       real 0.157  user 0.154  sys 0.003
#      t2       real 0.139  user 0.136  sys 0.003

loop_max=${loop_max:-10000}
. ./t-lib.sh ; f=$random_file

t1 ()
{
    for i in $(seq $loop_max)
    do
        if [ "1" = "1" ]; then
            if [ "1" = "1" ]; then
                if [ "1" = "1" ]; then
                    :
                fi
            fi
        fi
    done
}

t2 ()
{
    for i in $(seq $loop_max)
    do
        if [  "1" = "1" ] && [  "1" = "1" ] && [  "1" = "1" ]
        then
           :
        fi
    done
}

t="\
:t t1
:t t2
"

if [ "$source" ]; then
     :
elif [ "$run" ]; then
    "$@"
else
    RunTests "$t" "$@"
fi

# End of file
