#! /bin/bash
#
# Q: for-loop: ((...)) vs {1..N} vs $(seq N) vs POSIX i++
# A: The {1..N} and $(seq N) are very fast.
#
# t1 real    0m0.003s for i in {1..N}
# t2 real    0m0.004s for i in $(seq ...)
# t3 real    0m0.006s for ((i=0; i < N; i++))
# t4 real    0m0.010s while [ $i -le $N ] ... i++
#
# Notes:
#
# A simple, elegant, and practical winner: $(seq N)
#
# {1..N} problem: The Bash brace
# expansion cannot be parameterized, so it
# is only useful if N is known beforehand.
#
# However, all loops are so fast that the
# numbers don't mean much. The POSIX while-loop
# variant was slightly slower in all subsequent
# tests.

# Make user's setting take precedence:
# loop_max=100 ./<file>.sh

[ "${loop_max:+user}" = "user" ] && loop_count=$loop_max

. ./t-lib.sh ; f=$random_file

loop_max=${loop_count:-1000}

t1()
{
    for i in {1..1000}
    do
        item=$i
    done
}

t2()
{
    for i in $(seq $loop_max)
    do
        item=$i
    done
}

t3()
{
    for ((i=0; i <= $loop_max; i++))
    do
        item=$i
    done
}

t4()
{
    i=0
    while [ $i -le $loop_max ]
    do
        i=$((i + 1))  # POSIX
        item=$i
    done
}

t t1
t t2
t t3
t t4

# End of file
