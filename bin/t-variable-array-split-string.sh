#! /usr/bin/env bash
#
# Q: Split string into an array by IFS?
# A: It is about 5 times faster to use local IFS than use Bash array `<<<` HERE STRING
# priority: 8
#
#     t2 real  0.011 IFS= eval ...
#     t1 real  0.021 (array)
#     t3 real  0.098 read -ra
#
# Code:
#
#     t1 IFS=":" eval 'array=($PATH)'
#     t2 saved=$IFS; IFS=":"; array=($PATH)'; IFS=$saved
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

word_count=${word_count:-300}

Setup ()
{
    string=""

    for i in $(seq $word_count)
    do
        string=" $string $i"
    done
}

# Hide test case from other Shells
t1 () { : ; } # stub
t2 () { : ; } # stub
t3 () { : ; } # stub

cat << 'EOF' > t.bash
t1 ()
{
    # Enable local '-f' feature
    #
    # Safeguard "($string)" from
    # undergoing pathname expansion
    #
    # Not really relevant in <test case>
    # but reminds to use it in
    # production code

    local -
    set -f

    for i in $(seq $loop_max)
    do
        # Bash.
        #
        # NOTE: POSIX require 'command' before
        # special keywords like "eval" in order
        # to allow assignments in the same line
        #
        #  var=value command eval <statement>

        IFS=":" eval 'array=($string)'
        item=${array[0]}
    done
}

t2 ()
{
    for i in $(seq $loop_max)
    do
        # Localize IFS Bash, Ksh
        saved=$IFS
        array=($string)
        IFS=$saved

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
EOF

IsFeatureArrays && . ./t.bash

Setup

t="\
:t t1 IsShellBash
:t t2 IsFeatureArrays
:t t3 IsFeatureArrays
"

RunTests "$t" "$@"

rm --force t.bash

# End of file
