#! /bin/bash
#
# Q: Will prefilter grep + loop help compared to straight loop?
# A: Yes, using external grep + loop is 2x faster
#
# t1a real    0m1.063s loop: case glob
# t1b real    0m1.059s loop: bash glob [[ ]]
# t2  real    0m0.424s grep before loop
#
# Code:
#
# while read ... done < file        # t1a
# while read ... done < file        # t1b
# grep | while ... done             # t2
#

. ./t-lib.sh ; f=$random_file

loop_max=${loop_count:-10}

tmp=t.tmp

t1a ()
{
    i=1
    while [ $i -le $loop_max ]
    do
        i=$((i + 1))
        while read -r line
        do
            case "$i" in
                *0*) found=$line
                     ;;
            esac
        done < $f
    done
}

t1b ()
{
    i=1
    while [ $i -le $loop_max ]
    do
        i=$((i + 1))
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
    i=1
    while [ $i -le $loop_max ]
    do
        i=$((i + 1))
        grep "0" $f | while read -r line
        do
            found=$line
        done
    done
}

t t1a
t t1b
t t3

# End of file
