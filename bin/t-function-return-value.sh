#! /bin/bash
#
# Q: Bash name ref to return values vs val=$(funcall)
# A: Using name ref is about 40x faster
#
# t1 real    0m0.089s t1 $(funcall)
# t2 real    0m0.002s t2 funcall nameref
#
# Code:
#
# fn(): ... echo "<value>"                 # t1
# fn(): local -n ret=$1; ... ret="<value>" # t2

. ./t-lib.sh ; f=$random_file

f1()
{
    result="return value"
    echo "$result"
}

f2()
{
    local -n retval=$1  # nameref attribute, a reference to variable

    result="return value"
    retval="$result"
}

t1()
{
    val=""

    for i in {1..100}
    do
        val=$(f1)
    done
}

t2()
{
    val=""

    for i in {1..100}
    do
        f2 val
    done
}

t t1
t t2

# End of file
