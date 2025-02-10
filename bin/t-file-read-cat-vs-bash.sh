#! /bin/bash
#
# Q: Is Bash $(< FILE) faster than $(cat FILE)?
# A: The $(< FILE) is about 2x faster for small files
#
# real    0m0.166s $(< file)
# real    0m0.365s $(cat file)
#
# Notes:
#
# With big files, cat(1) is much faster:
#
# . t-lib.sh
# RandomWordsDictionary 1M > t.1M
#
# time bash -c 'cat t.1M > /dev/null'
# real    0m0.014s
#
# time bash -c 's=$(< t.1M); echo "$s" > /dev/null'
# real  0m0.055s

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
