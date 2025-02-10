#! /bin/bash
#
# Q: Bash variable ref to return values vs val=$(funcall)
# A: variable name ref is about 40x faster, $(funcall) is slow.
#
# real    0m0.089s t1 $(funcall)
# real    0m0.002s t2 funcall nameref

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

t ()
{
    echo -n "# $1"
    time $1
    echo
}

t t1
t t2

# End of file
