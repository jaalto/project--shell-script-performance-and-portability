#! /bin/bash
#
# Q: POSIX `i=$((i + 1))` vs `((i++))` vs `let i++` etc.
# A: No noticeable difference, POSIX `i=$((i + 1))` will do fine
# priority: 1
#
#     t1 real 0m0.025s ((i++))      Bash
#     t2 real 0m0.047s let i++      Bash
#     t3 real 0m0.045s i=$((i + 1)) POSIX
#     t4 real 0m0.061s : $((i++))   POSIX (true; with side effect)
#
# Notes:
#
# The tests were using 10 000 repeats, which is
# unrealistic for any program. There really is no
# practical difference whichever you choose. The
# portable POSIX version works in all shells:
# `i=$((i + 1))`.

[ "${loop_max:+user}" = "user" ] && loop_count=$loop_max

. ./t-lib.sh ; f=$random_file

loop_max=${loop_count:-10000}

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
        item=$((item + 1))  # traditional
    done
}

t4 ()
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
t t4

# End of file
