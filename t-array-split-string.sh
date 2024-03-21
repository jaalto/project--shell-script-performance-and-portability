#! /bin/bash
#
# real    0m0.025s read -ra
# real    0m0.005s eval     (!)

declare -a array
string=$(echo {1..100})

t1 ()
{
    for i in {1..100}
    do
        IFS=', ' read -ra array <<< "$string"
        i=${array[0]}
    done
}

t2 ()
{
    for i in {1..100}
    do
        # IFS is temporary with 'eval'
        IFS=', ' eval 'array=($string)'
        i=${array[0]}
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
