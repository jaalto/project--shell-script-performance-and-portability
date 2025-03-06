#! /bin/bash
#
# Q: Howabout Bash nameref to return value vs val=$(funcall)
# A: It is about 40x faster to use nameref to return value from a function
#
#     t1 real 0m0.089s t1 $(funcall)
#     t2 real 0m0.002s t2 funcall nameref
#
# Code:
#
#     t1 fn(): ... echo "<value>"
#     t2 fn(): local -n ret=$1; ... ret="<value>"

. ./t-lib.sh ; f=$random_file

f1 ()
{
    result="return value"
    echo "$result"
}

f2 ()
{
    local -n retval=$1  # nameref attribute, a reference to variable

    result="return value"
    retval="$result"
}

t1 ()
{
    val=""

    for i in $(seq $loop_max)
    do
        val=$(f1)
    done
}

t2 ()
{
    val=""

    for i in $(seq $loop_max)
    do
        f2 val
    done
}

t t1
t t2

# End of file
