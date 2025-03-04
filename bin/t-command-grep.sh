#! /bin/bash
#
# Q: In grep, is option --fixed-strings faster?
# A: Not much difference to --extended-regexp, --perl-regexp, --ignore-case
# priority: 2
#
# Q: Is using parallel(1) with grep even faster?
# A: Yes, parallel is effective (1000 lines in test file)
# priority: 5
#
# t1pure     real   0m0.382s LANG=C --fixed-strings
# t1utf8     real   0m0.389s LANG=C.UTF-8 --fixed-strings
# t1extended real   0m0.382s LANG=C --extended-regexp
# t1perl     real   0m0.381s LANG=C --perl-regexp
#
# t2icasef   real   0m0.386s LANG=C --ignore-case --fixed-strings
# t2icasee   real   0m0.397s LANG=C --ignore-case --extended-regexp
#
# GNU parallel(1). Split file into chunks and run grep(1) in parallel
# for each chunk. Suprisingly with test files ranging from 1000 to 10000
# lines was enough to benefit from parallel processing.
#
# t_parallel1 real  0m0.233s <defaults>
# t_parallel2 real  0m0.300s --block-size 1k
# t_parallel3 real  0m0.245s -N 1k (grep instance for every 1k lines)

. ./t-lib.sh # ; f=$random_file

# can be set externally
re=${re:-'ad'}
size=${size:-1k}

dict=t.random.dictionary.$size
f=$dict

AtExit ()
{
    [ "$dict" ] || return 0
    [ -f "$dict" ] || return 0

    rm --force "$dict"
}

Setup ()
{
    RandomWordsDictionary $size > $dict
}

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

t1()
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
        grep --quiet --ignore-case --fixed-strings "$re" $f
    done
}

t2icasee ()
{
    for i in $(seq $loop_max)
    do
        grep --quiet --ignore-case --extended-regexp "$re" $f
    done
}

t_parallel1()
{
    parallel --pipe grep --quiet --fixed-strings "$re" < $f
}

t_parallel2()
{
    parallel --pipe --block-size 1k grep --quiet --fixed-strings "$re" < $f
}

t_parallel3()
{
    parallel --pipe --max-replace-args 1k grep --quiet --fixed-strings "$re" < $f
}

trap AtExit EXIT HUP INT QUIT TERM

Setup
echo "test file: $(ls -l $f)"

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
