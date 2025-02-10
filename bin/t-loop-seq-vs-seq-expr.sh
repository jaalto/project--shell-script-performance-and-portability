#! /bin/bash
#
# Q: Bash {1..N} vs $(seq N) vs POSIX i++
# A: The {1..N} and $(seq N) are very fast.
#
# t1 real    0m0.003s for i in {N..M}
# t2 real    0m0.007s for i in $(seq ...)
# t3 real    0m0.017s for [ $i -le $max ] ... i++

. ./t-lib.sh ; f=$random_file

loop_max=${loop_count:-1000}

t1 ()
{
    for i in {1..1000}  # Cannot parametrisize
    do
        item=$i
    done
}

t2 ()
{
    for i in $(seq $loop_max)
    do
        itemp=$i
    done
}

t3 ()
{
    for i in $(seq $loop_max)
    do
        item=$i
    done
}

t t1
t t2
t t3

# End of file
