#! /bin/bash
#
# Q: split string into an array: read vs eval?
# A: eval is 2x faster
#
# t1 real    0m0.012s eval
# t2 real    0m0.025s read -ra
#
# Code:
#
# string=$(echo {1..100})
# read -ra array <<< "$string"  # t1
# eval 'array=($string)'        # t2
#
# Notes:
#
# The reason is probably that `<<<` uses a
# temporary file, whereas `eval` operates
# entirely in memory.

. ./t-lib.sh ; f=$random_file

string=$(echo {1..100})

t1()
{
    for i in $(seq $loop_max)
    do
        IFS=', ' eval 'array=($string)'
        item=${array[0]}
    done
}

t2()
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
