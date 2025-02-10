#! /bin/bash
#
# Q: What is the fastest way to read a file's size?
# A: wc -c; or stat() but not POSIX.
#
# real    0m0.269s stat
# real    0m0.360s wc -l ; GNU version efectively like stat()
# real    0m0.461s ls + awk

. ./t-lib.sh ; f=$random_file

t1 ()
{
    for i in {1..100}
    do
        size=$(stat -c %s "$f")
    done
}

t2 ()
{
    for i in {1..100}
    do
        # More portable
        #
        # GNU  coreutils implementation optimizes this
        # away using fstat(). Efectively same as stat().

        size=$(wc -c "$f")
    done
}

t3 ()
{
    for i in {1..100}
    do
        size=$(ls -l "$f" | awk '{print $5; exit}')
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
t t3

# End of file
