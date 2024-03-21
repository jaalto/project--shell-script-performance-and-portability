#! /bin/bash
#
# Q: In grep, is --fixed-strings faster?
# A: yes
#
# Q: Is parallel(1) + grep faster?
# A: only for large files (> 50 000 lines)
#
# t1pure    real    0m0.332s LANG=C --fixed-strings
# t1	    real    0m0.398s --fixed-strings
# t1icase   real    0m0.377s --fixed-strings --ignore-case
#
# t2	    real    0m0.338s --extended-regexp
# t2icase   real    0m0.488s --extended-regexp --ignore-case
#
# t_parallel1 real    0m0.226s <defaults>
# t_parallel2 real    0m0.638s --block-size 1k
# t_parallel3 real    0m0.300s -N 1k (grep instance for every 1k lines)

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

t_parallel1 ()
{
    # Suprisingly file size (10 000) was enough to benefit parallel

    parallel --pipe grep --quiet --fixed-strings '12' < $rand
}

t_parallel2 ()
{
    # Suprisingly file size (10 000) was enough to benefit parallel

    parallel --pipe --block-size 1k grep --quiet --fixed-strings '12' < $rand
}

t_parallel3 ()
{
    # Suprisingly file size (10 000) was enough to benefit parallel

    parallel --pipe --max-replace-args 1k grep --quiet --fixed-strings '12' < $rand
}

t t1pure
t t1
t t1icase

t t2
t t2icase

t t_parallel1
t t_parallel2
t t_parallel3

# End of file
