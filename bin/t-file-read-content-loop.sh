#! /bin/bash
#
# Q: Fastest to process lines: readarray vs 'while read < file' ?
# A: readarray/mapfiles+for is 2x faster than 'while read < file'
#
# t1  real       0m0.037s t1  mapfile + for
# t2a real       0m0.036s t2a readarray + for
# t2b real       0m0.081s t2b readarray + for ((i++))
# t3  real       0m0.085s t3  while read < file
#
# Code:
#
#  mapfile -t array < file   ; for <array> ...        # t1
#  readarray -t array < file ; for i in <array> ...   # t2a
#  readarray -t array < file ; for ((i... <array> ... # t2b
#  while read ... done < file                         # t3
#
# Notes:
#
# In Bash, the readarray built-in is a synonym for mapfile,
# so they should behave equally.

. ./t-lib.sh ; f=$random_file

t1()
{
    local -a array
    array=()

    mapfile -t array < $f

    for i in "${array[@]}"
    do
        i=$i
    done
}

t2a ()
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

t2b ()
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

t3()
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
