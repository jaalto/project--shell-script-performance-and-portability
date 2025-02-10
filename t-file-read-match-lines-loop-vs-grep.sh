#! /bin/bash
#
# Q: find lines. Will grep hep before loop?
# A: Yes, using external grep + loop is 2x faster
#
# real    0m1.063s loop: case glob
# real    0m1.059s loop: bash glob [[ ]]
# real    0m0.424s grep before loop
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
    for i in {1..10}
    do
        while read -r line
        do
            case "$i" in
                *0*) found=$line
                     ;;
            esac
        done < $f
    done
}

t2 ()
{
    for i in {1..10}
    do
        while read -r line
        do
            if [[ $i = *0* ]]; then
                found=$line
            fi
        done < $f
    done
}

t3 ()
{
    for i in {1..10}
    do
        grep "0" $f | while read -r line
        do
            found=$line
        done
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
