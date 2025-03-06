#! /bin/bash
#
# Q: Split string into an array: `eval` vs `read`?
# A: It is about 2-3x faster to use `eval`
#
#     t1 real    0m0.012s eval
#     t2 real    0m0.025s read -ra
#
# Code:
#
#     t1 IFS=":" eval 'array=($PATH)'
#     t2 IFS=":" read -ra array <<< "$PATH"
#
# Notes:
#
# This test involves splitting by an arbitrary
# character, which requires setting a local
# IFS for the execution of the command.
#
# The reason why `<<<` is slower is that it
# uses a pipe buffer (in latest Bash),
# whereas `eval` operates entirely in memory.

. ./t-lib.sh ; f=$random_file

string=$(echo {1..100})

t1 ()
{
    for i in $(seq $loop_max)
    do
        IFS=', ' eval 'array=($string)'
        item=${array[0]}
    done
}

t2 ()
{
    for i in $(seq $loop_max)
    do
        # Slow, because internally uses temporary file to store STRING.
        IFS=', ' read -ra array <<< "$string"
        item=${array[0]}
    done
}

t t1
t t2

# End of file
