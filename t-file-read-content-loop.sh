#! /bin/bash
#
# Q: Fastest to process lines: 'while read < FILE' or readarray
# A: readarray with 'for' is the fastest
#
# NOTE: readarray built-in is a synonym for mapfile.
#
# real	0m0.037s t1  mapfile
# real	0m0.033s t2a readarray + for
# real	0m0.081s t2b readarray + for ((i++))  (!)
# real	0m0.103s t3  while read < file

. ./t-lib.sh ; f=$rand

t1 ()
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

t3 ()
{
    while read i
    do
        i=$i
    done < $f
}

t ()
{
    echo -n "# $1"
    time $1
    echo
}

t t1
t t2a
t t2b
t t3

# End of file
