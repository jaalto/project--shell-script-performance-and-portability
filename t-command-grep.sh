#! /bin/bash
#
# Q: In grep, is --fixed-strings faster?
# A: yes
#
# t1pure    real    0m0.332s LANG=C --fixed-strings
# t1	    real    0m0.398s --fixed-strings
# t1icase   real    0m0.377s --fixed-strings --ignore-case
# t2	    real    0m0.338s --extended-regexp
# t2icase   real    0m0.488s --extended-regexp --ignore-case

. ./t-lib.sh ; f=$rand

t1pure ()
{
    for i in {1..100}
    do
        LANG=C grep --quiet --fixed-strings '12' $rand
    done
}

t1 ()
{
    for i in {1..100}
    do
        grep --quiet --fixed-strings '12' $rand
    done
}

t1icase ()
{
    for i in {1..100}
    do
        grep --quiet --fixed-strings --ignore-case '12' $rand
    done
}

t2 ()
{
    for i in {1..100}
    do
        grep --quiet --extended-regexp '12' $rand
    done
}

t2icase ()
{
    for i in {1..100}
    do
        grep --quiet --extended-regexp --ignore-case '12' $rand
    done
}

t ()
{
    echo -n "# $1"
    time $1
    echo
}

t t1pure
t t1
t t1icase

t t2
t t2icase

# End of file
