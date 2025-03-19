#! /bin/bash
#
# Q: In grep, is option --fixed-strings faster?
# A: No notable difference between --extended-regexp, --perl-regexp, --ignore-case
# priority: 2
#
#     t1pure     real 0m0.382s LANG=C --fixed-strings
#     t1utf8     real 0m0.389s LANG=C.UTF-8 --fixed-strings
#     t1extended real 0m0.382s LANG=C --extended-regexp
#     t1perl     real 0m0.381s LANG=C --perl-regexp
#
#     t2icasef   real 0m0.386s LANG=C --ignore-case --fixed-strings
#     t2icasee   real 0m0.397s LANG=C --ignore-case --extended-regexp
#
# Notes:
#
# The tests suggest that with typical file sizes
# (100 kB), the choice between the "C" locale and
# UTF-8 is not significant. Similarly, the type of
# regular expression or case sensitivity does not
# seem to be a major factor.
#
# However, on some operating systems and with large
# files, there have been reports of significant
# speed improvements by using the "C" locale,
# enabling `--fixed-strings`, and avoiding
# `--ignore-case`.

. ./t-lib.sh # ; f=$random_file

RequireDictionary "t-command-grep.sh"

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

trap AtExit EXIT HUP INT QUIT TERM

Setup
echo "test file: $(ls -l $f)"

t t1pure
t t1utf8
t t1extended
t t1perl

t t2icasef
t t2icasee

# End of file
