#! /bin/bash
#
# Q: How much is $(< FILE) faster than $(cat FILE)?
# A: bash $(< FILE) is about 2x faster
#
# real    0m0.166s $(< file)
# real    0m0.365s $(cat file)
#
# NOTES: out of interest, cat is faster with big files:
#
# time bash -c 'cat FILE_1M > /dev/null'
# real    0m0.014s
#
# time bash -c 's=$(< FILE_1M); echo "$s" > /dev/null'
# real  0m0.086s

. ./t-lib.sh ; f=$random_file

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
