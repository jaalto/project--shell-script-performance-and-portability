#! /bin/bash
#
# Q: In grep, is --fixed-strings faster?
# A: Not much difference to --extended-regexp or --perl-regexp
#
# Q: Is using parallel(1) with grep even faster?
# A: Not worth for small files. Yes with bigger ones (test file: 10 000 lines)
#
# t1pure     real   0m0.338s LANG=C --fixed-strings
# t1utf8     real   0m0.372s LANG=C.UTF-8 --fixed-strings
# t1extended real   0m0.346s LANG=C --extended-regexp
# t1perl     real   0m0.349s LANG=C --perl-regexp
#
# t2icasef   real    0m0.394s LANG=C --fixed-strings --ignore-case
# t2icasee   real    0m0.419s LANG=C --extended-regexp --ignore-case
#
# GNU parallel(1). Split file into chunks and run grep(1) in parallel
# for each chunk.
#
# t_parallel1 real  0m0.226s <defaults>
# t_parallel2 real  0m0.653s --block-size 1k
# t_parallel3 real  0m0.300s -N 1k (grep instance for every 1k lines)

. ./t-lib.sh ; f=$random_file

re=${re:-'12'}

t1pure ()
{
    for i in $(seq $loop_max)
    do
        LANG=C grep --quiet --fixed-strings "$re" $f
    done
}

t1utf8 ()
{
    for i in $(seq $loop_max)
    do
        LANG=C.UTF-8 grep --quiet --fixed-strings "$re" $f
    done
}

t1 ()
{
    i=1
    while [ $i -le $loop_max ]
    do
        grep --quiet --extended-regexp "$re" $f
    done
}

t1extended ()
{
    for i in $(seq $loop_max)
    do
        LANG=C grep --quiet --extended-regexp "$re" $f
    done
}

t1perl ()
{
    for i in $(seq $loop_max)
    do
        LANG=C grep --quiet --perl-regexp "$re" $f
    done
}

t2icasef ()
{
    for i in $(seq $loop_max)
    do
        grep --quiet --fixed-strings --ignore-case "$re" $f
    done
}

t2icasee ()
{
    for i in $(seq $loop_max)
    do
        grep --quiet --extended-regexp --ignore-case "$re" $f
    done
}

t_parallel1 ()
{
    # Suprisingly file size (10 000) was enough to benefit parallel

    parallel --pipe grep --quiet --fixed-strings "$re" < $f
}

t_parallel2 ()
{
    # Suprisingly file size (10 000) was enough to benefit parallel

    parallel --pipe --block-size 1k grep --quiet --fixed-strings "$re" < $f
}

t_parallel3 ()
{
    # Suprisingly file size (10 000) was enough to benefit parallel

    parallel --pipe --max-replace-args 1k grep --quiet --fixed-strings "$re" < $f
}

t t1pure
t t1utf8
t t1extended
t t1perl

t t2icasef
t t2icasee

if ! command -v parallel > /dev/null; then
    Warn "INFO: no parallel(1). Skipping tests."
else
    # Run parallel tests
    t t_parallel1
    t t_parallel2
    t t_parallel3
fi

# End of file
