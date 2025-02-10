#! /bin/bash
#
# Q: split string into array: read vs eval?
# A: eval is 5x faster
#
# t1 real    0m0.025s read -ra
# t2 real    0m0.005s eval     (!)
#
# Code:
#
# string=$(echo {1..100})
# read -ra array <<< "$string"  # t1
# eval 'array=($string)'        # t2

. ./t-lib.sh ; f=$random_file

declare -a array
string=$(echo {1..100})

t1 ()
{
    i=1
    while [ $i -le $loop_max ]
    do
        i=$((i + 1))
        # Slow, because internally uses temporary file to store STRING.
        IFS=', ' read -ra array <<< "$string"
        i=${array[0]}
    done
}

t2 ()
{
    i=1
    while [ $i -le $loop_max ]
    do
        i=$((i + 1))
        IFS=', ' eval 'array=($string)'
        i=${array[0]}
    done
}

t t1
t t2

# End of file
