#! /bin/bash
#
# Q: POSIX `[ $var = 1 ]` vs Bash `[[ $var = 1 ]]` etc
# A: No notable difference.
# priority: 0
#
#     t1val     real 0m0.002s [ "$var" = "1" ] # POSIX
#     t2val     real 0m0.003s [[ $var = 1 ]]   # Bash
#
#     t1empty   real 0m0.002s [ ! "$var" ]     # modern POSIX
#     t2empty   real 0m0.002s [ -z "$var" ]    # archaic POSIX
#     t3empty   real 0m0.003s [[ ! $var ]]     # Bash
#
# Notes:
#
# Only with very high amount of repeats, there are
# slight differences in favor of Bash `[[ ]]`.
#
#     loop_max=10000 ./statement-if-posix-vs-bash.sh
#
#     t1val          real 0.055  user 0.054  sys 0.000  POSIX
#     t2val          real 0.032  user 0.030  sys 0.003  [[ ]]
#
#     t1empty        real 0.052  user 0.045  sys 0.007  POSIX
#     t2empty        real 0.053  user 0.050  sys 0.003
#     t3empty        real 0.032  user 0.026  sys 0.007  [[ ]]

. ./t-lib.sh ; f=$random_file

t1val ()
{
    var="1"
    for i in $(seq $loop_max)
    do
        [ "$var" = "1" ]
    done
}

t2val ()
{
    var="1"
    for i in $(seq $loop_max)
    do
        [[ $var = 1 ]]
    done
}

t1empty ()
{
    var="abc"
    for i in $(seq $loop_max)
    do
        [ ! "$var" ]
    done
}

t2empty ()
{
    var="abc"
    for i in $(seq $loop_max)
    do
        [ -z "$var" ]
    done
}

t3empty ()
{
    var="abc"
    for i in $(seq $loop_max)
    do
        [[ ! $var ]]
    done
}


t t1val
t t2val
t t1empty
t t2empty
t t3empty

# End of file
