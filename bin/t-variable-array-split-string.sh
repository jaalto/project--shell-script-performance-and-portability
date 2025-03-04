#! /bin/bash
#
# Q: split string into an array: eval vs read?
# A: eval is 2-3x faster
#
# t1 real    0m0.012s eval
# t2 real    0m0.025s read -ra
#
# Code:
#
# IFS=":" eval 'array=($PATH)'        # t1
# IFS=":" read -ra array <<< "$PATH"  # t2
#
# Notes:
#
# This test involves splitting by an arbitrary
# character, which requires setting a local
# IFS for the execution of the command.
#
# The reason why `<<<` is slower is that it
# uses a temporary file, whereas `eval` operates
# entirely in memory.

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
