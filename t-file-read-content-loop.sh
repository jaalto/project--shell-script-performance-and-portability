#! /bin/bash
#
# Q: Which is faster to process file: while read < FILE or readarray
# A: readarray is much faster
#
# NOTE: readarray builtin, is a synonym for mapfile
#
# real	0m0.041s t1  mapfile
# real	0m0.036s t2a readarray + for   (!)
# real	0m0.076s t2b readarray + while
# real	0m0.088s t3  while read < file

. ./t-lib.sh ; f=$rand

t1 ()
{
    mapfile -t a < $f

    for i in "${a[@]}"
    do
        i=$a[$i]
    done
}

t2a ()
{
    readarray -t a < $f

    for i in "${a[@]}"
    do
        i=$a[$i]
    done
}

t2b ()
{
    readarray -t a < $f
    size=${a#[@]}
    i=0

    while [ $i -lt $size ]
    do
        ((i++))
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
