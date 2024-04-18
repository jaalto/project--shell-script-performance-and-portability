#! /bin/bash
#
# Q: Bash seq expr {N..M} vs $(seq ...)
# A: The {N..M} sequence expression is faster but both are real fast
#
# real    0m0.003s $(seq ...)
# real    0m0.006s {N..M}

# . ./t-lib.sh ; f=$rand
# tmp=t.tmp

t1 ()
{
    for i in {1..1000}
    do
        i=$i
    done
}

t2 ()
{
    for i in $(seq 1000)
    do
        i=$i
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
