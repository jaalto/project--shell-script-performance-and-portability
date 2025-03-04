#! /bin/bash
#
# Q: Is using parallel(1) with grep even faster?
# A: Yes, parallel is effective (1000 lines in test file)
# priority: 5
#
# t0  real  0m0.233s grep baseline
# t1a real  0m0.300s --block-size <default> (Linux 64k)
# t1b real  0m0.245s -block-size <default> --pipepart
# t2  real  0m0.245s --block-size 1k (grep instance for every 1k lines)
# t3  real  0m0.245s --block-size 16k
# t4  real  0m0.245s --block-size 32k
#
# Notes:
#
# GNU parallel(1) tests. Split file into chunks and run grep(1)
# in parallel for each chunk.
#
# Suprisingly with test files ranging from 1000 to 10000 lines
# was enough to benefit from parallel processing.

. ./t-lib.sh # ; f=$random_file

LANG=C

# can be set externally
re=${re:-'ad'}
size=${size:-10k}

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

t0 ()  # Baseline
{
    grep --quiet --fixed-strings "$re" $f
}

t1a ()
{
    # Use default values. In Linux blocksize is around 64k
    parallel --pipe grep --quiet --fixed-strings "$re" < $f
}

t1b ()
{
    parallel --pipepart grep --quiet --fixed-strings "$re" < $f
}

t2 ()
{
    parallel --pipe --block-size 1k grep --quiet --fixed-strings "$re" < $f
}

t3 ()
{
    parallel --pipe --block-size 16k grep --quiet --fixed-strings "$re" < $f
}

t4 ()
{
    parallel --pipe --block-size 32k grep --quiet --fixed-strings "$re" < $f
}

trap AtExit EXIT HUP INT QUIT TERM

Setup
echo "test file: $(ls -l $f)"

if ! command -v parallel > /dev/null; then
    Warn "INFO: no parallel(1). Skipping tests."
else

    t t0

    if IsCygwin; then
        echo "# t1 ... skip on Cygwin (no 64k blocksize in parallel)"
    else
        t t1a
        t t1b
    fi

    t t2
    t t3
    t t4
fi

# End of file
