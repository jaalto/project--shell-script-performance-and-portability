#! /usr/bin/env bash
#
# Q: Is `grep' faster with `parallel`?
# A: In typical files, grep is much faster. Use `parallel`only with huge files.
# priority: 1
#
#     t0  real 0m0.005s grep baseline
#     t1a real 0m0.210s --block-size <default> --pipepart
#     t1b real 0m0.240s --block-size <default> (Linux)
#     t2  real 0m0.234s --block-size 64k
#     t3  real 0m0.224s --block-size 32k
#
# Notes:
#
# The idea was to split file into chunks and run
# grep` in parallel for each chunk.
#
# The `grep` by itself is very fast. The startup time
# of `parallel`, implemented in `perl`, is taking the
# toll with the parallel if the file sizes are
# relatively small (test file: ~600 lines).

. ./t-lib.sh # ; f=$random_file

FILE="t-command-grep-parallel.sh"
RequireDictionary "$FILE"
RequireParallel "$FILE"

LANG=C

# can be set externally
re=${re:-'ad'}
size=${size:-50k}

f=$TMPBASE.random.dictionary.$size

Setup ()
{
    RandomWordsDictionary $size > $f
}

Info ()
{
    echo "test file: $(ls -l $f)"
    echo "test file: lines $(wc -l $f)"
}

t0 ()  # Baseline
{
    grep --quiet --fixed-strings "$re" $f
}

t1a ()
{
    parallel --pipepart grep --quiet --fixed-strings "$re" < $f
}

t1b ()
{
    # Use default values. In Linux blocksize is around 64k
    parallel --pipe grep --quiet --fixed-strings "$re" < $f
}

t2 ()
{
    parallel --pipe --block-size 32k grep --quiet --fixed-strings "$re" < $f
}

t3 ()
{
    parallel --pipe --block-size 16k grep --quiet --fixed-strings "$re" < $f
}

t="\
:t t0
:t t1a IsOsCygwin
:t t1b IsOsCygwin
:t t2
:t t3
"

SetupTrapAtExit
Setup

if [ ! "$source" ]; then
    Info
    RunTests "$t" "$@"
fi

# End of file
