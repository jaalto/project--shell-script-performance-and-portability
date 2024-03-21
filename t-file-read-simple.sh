#! /bin/bash
#
# real    0m0.166s $(< file)
# real    0m0.365s $(cat file)

. ./t-lib.sh ; f=$rand

tmp=t.tmp

t1 ()
{
    for i in {1..100}
    do
        val=$(< $f)
    done
}

t2 ()
{
    for i in {1..100}
    do
        val=$(cat $f)
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
