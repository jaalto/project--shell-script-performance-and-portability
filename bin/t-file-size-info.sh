#! /bin/bash
#
# Q: What is the fastest way to read a file's size?
# A: GNU wc -c. Or stat() but it is not in POSIX (not portable)
#
# t1 real    0m0.288s stat -c file
# t2 real    0m0.360s wc -l file; GNU version efectively like stat()
# t3 real    0m0.461s ls -l + awk

. ./t-lib.sh ; f=$random_file

t1 ()
{
    i=1
    while [ $i -le $loop_max ]
    do
        i=$((i + 1))
        size=$(stat -c %s "$f")
    done
}

t2 ()
{
    i=1
    while [ $i -le $loop_max ]
    do
        i=$((i + 1))
        # More portable
        #
        # GNU  coreutils implementation optimizes this
        # away using fstat(). Efectively same as stat().

        size=$(wc -c "$f")
    done
}

t3 ()
{
    i=1
    while [ $i -le $loop_max ]
    do
        i=$((i + 1))
        size=$(ls -l "$f" | awk '{print $5; exit}')
    done
}

t t1
t t2
t t3

# End of file
