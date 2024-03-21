#! /bin/bash
#
# real	0m0.088s t2  while read
# real	0m0.076s t2a readarray + while
# real	0m0.044s t2b readarray + for   (!)
# real	0m0.045s t3  mapfile

f=t.random.numbers.tmp

if [ ! -f $f ]; then
    n=10000   # 10 000 numbers
    perl -e "print int(rand(2**14-1)) . qq(\n) for 1..$n" > $f
fi

t1 ()
{
    while read i
    do
        i=$i
    done < $f
}

t2a ()
{
    readarray -t a < $f
    size=${a#[@]}
    i=0

    while [ $i -lt $size ]
    do
        ((i++))
    done
}

t2b ()
{
    readarray -t a < $f

    for i in "${a[@]}"
    do
        i=$a[$i]
    done
}

t3 ()
{
    mapfile -t a < $f

    for i in "${a[@]}"
    do
        i=$a[$i]
    done
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
