#! /bin/bash
#
# Q: POSIX ': $((i++))' vs ((i++)) vs let i++?
# A: No noticeable difference
#
# t1     real    0m0.005s ((i++))
# t2     real    0m0.005s let i++
# t3     real    0m0.007s : $((i++))

. ./t-lib.sh ; f=$random_file

t1 ()
{
    item=0
    for i in $(seq $loop_max)
    do
        ((item++))
    done
}

t2 ()
{
    item=0
    var="abc"
    for i in $(seq $loop_max)
    do
        let item++
    done
}

t3 ()
{
    item=0
    for i in $(seq $loop_max)
    do
        : $((item++))
    done
}

t t1
t t2
t t3

# End of file
