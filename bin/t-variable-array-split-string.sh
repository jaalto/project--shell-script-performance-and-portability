#! /bin/bash
#
# Q: Split string into an array by IFS?
# A: It is about 4-5 times faster to save/restore IFS than use Bash array `<<<` injecton
# priority: 8
#
#     t1 real 0m0.005s (array)
#     t2 real 0m0.011s IFS= eval ...
#     t3 real 0m0.030s read -ra
#
# Code:
#
#     t1 saved=$IFS; IFS=":"; array=($PATH)'; IFS=$saved
#     t2 IFS=":" eval 'array=($PATH)'
#     t3 IFS=":" read -ra array <<< "$PATH"
#
# Notes:
#
# This test involves splitting by an arbitrary
# character, which requires setting a local
# `IFS` for the execution of the command.
#
# The local IFS can be defined for one
# statement only if `eval` is used.
#
# The reason why `<<<` is slower is that it
# uses a pipe buffer (in latest Bash),
# whereas `eval` operates entirely in memory.
#
# *Warning*
#
# Please note that using the `(list)`
# statement will undergo pathname expansion.
# Use it only in situations where the string does
# not contain any globbing characters
# like `*`, `?`, etc.
#
# You can prevent `(list)` to undergo pathname
# expansion inside function, by disabling it with:
#
#     local - set -f

. ./t-lib.sh ; f=$random_file

# Prepare string  string with 100 "words"
printf -v string "%s," {1..100}

t1 ()
{
    for i in $(seq $loop_max)
    do
        # Localize IFS....
        saved=$IFS
        array=($string)
        IFS=$saved

        item=${array[0]}
    done
}

t2 ()
{
    # Enable local '-f' feature
    #
    # Safeguard "($string)" from
    # undergoing pathname expansion
    #
    # Not really relevant here, but
    # to remind you to use it in production
    # code

    local -
    set -f

    for i in $(seq $loop_max)
    do
        # local IFS for the statement only
        IFS=',' eval 'array=($string)'
        item=${array[0]}
    done
}

t3 ()
{
    for i in $(seq $loop_max)
    do
        # Slow, because internally uses temporary file to store STRING.
        IFS=',' read -ra array <<< "$string"
        item=${array[0]}
    done
}

t t1
t t2
t t3

# End of file
