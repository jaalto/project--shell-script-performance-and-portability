#! /bin/bash
#
# Q: POSIX 'i=$((i + 1))' vs ((i++)) vs let i++ etc.
# A: No noticeable difference
#
# t1     real    0m0.005s ((i++))
# t2     real    0m0.005s let i++
# t3     real    0m0.007s : $((i++))
# t4     real    0m0.007s i=$((i + 1))

. ./t-lib.sh ; f=$random_file

loop_max=${max_count:-1000}

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

t4 ()
{
    item=0
    for i in $(seq $loop_max)
    do
        item=$((item + 1))  # traditional
    done
}

t t1
t t2
t t3
t t4

# End of file
