#! /bin/bash
#
# Q: Bash name ref to return values vs val=$(funcall)
# A: name ref is about 40x faster
#
# real    0m0.089s t1 $(funcall)
# real    0m0.002s t2 funcall nameref

. ./t-lib.sh ; f=$random_file

f1 ()
{
    a="done"
    echo $a
}

f2 ()
{
    local -n var  # nameref attribute, reference to variable
    var="done"
}

t1 ()
{
    local v=0

    for i in {1..100}
    do
        v=$(f1)
    done
}

t2 ()
{
    local v=0

    for i in {1..100}
    do
        f2 v
    done
}

t t1
t t2

# End of file
