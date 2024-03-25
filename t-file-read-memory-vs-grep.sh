#! /bin/bash
#
# Q: Is matching file in memory faster than grep?
# A: Yes, much faster
#
# NOTE: only the occurrance of regexp is tested. In grep, the -E
# is usually included.
#
# real    0m0.001s  t1 read to memory
# real    0m0.043s  t2 grep

. ./t-lib.sh ; f=$rand

cp $f $f.tmp
f=$f.1

RE="search.*this"

echo "$RE" >> $f

t1 ()
{
    read -N1000000 < $f

    for i in {1..10}
    do
        if [[ $REPLY =~ $RE1 ]]; then
            i=$1
        fi
    done
}

t2 ()
{
    for i in {1..10}
    do
        if grep --quiet --extended-regexp --files-without-match "$RE" $f
        then
            i=$1
        fi
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
rm -f $tmp

# End of file
