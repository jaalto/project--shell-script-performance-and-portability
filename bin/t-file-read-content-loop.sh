#! /bin/bash
#
# Q: Fastest way to process lines: 'while read < FILE' vs readarray
# A: readarray with 'for' loop is the fastest
#
# t1a real       0m0.033s t2a readarray + for
# t1b real       0m0.081s t2b readarray + for ((i++))
# t2  real       0m0.037s t1  mapfile
# t3  real       0m0.103s t3  while read < file
#
# Code:
#
#  readarray -t array < file ; for i in <array> ...   # t1a
#  readarray -t array < file ; for ((i... <array> ... # t1b
#  mapfile -t array < file   ; for <array> ...        # t2
#  while read ... done < file                       # t3
#
# Notes:
#
# In Bash, the readarray built-in is a synonym for mapfile.

. ./t-lib.sh ; f=$random_file

t1a ()
{
    local -a array
    array=()

    readarray -t array < $f

    local i

    for i in "${array[@]}"
    do
        i=$i
    done
}

t1b ()
{
    local -a array
    array=()

    readarray -t array < $f

    local i item

    for ((i = 0; i < ${#array[@]}; i++))
    do
        item=${array[i]}
    done
}

t2 ()
{
    local -a array
    array=()

    mapfile -t array < $f

    for i in "${array[@]}"
    do
        i=$i
    done
}

t3 ()
{
    while read -r i
    do
        i=$i
    done < $f
}

t t1
t t2a
t t2b
t t3

# End of file
