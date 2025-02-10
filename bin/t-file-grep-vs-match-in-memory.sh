#! /bin/bash
#
# Q: To check file for a match: read vs grep(1)?
# A: It is much faster to read file into memory for matching
#
# t1 real   0m0.183s read + case (inline)
# t2 real   0m0.184s read + bash regexp (separate file calls)
# t3 real   0m0.008s read + bash regexp (read file once + loop match)
# t4 real   0m0.396s external grep(1)
#
# Code:
#
# Notes
#
# Only for brief checks. Not a substitute for real
# regular expressions.

. ./t-lib.sh ; rand=$random_file

f=$rand.t.tmp
STRING=abc

AtExit ()
{
    [ "$f" ] || return 0
    rm --force "$f"
}

Setup ()
{
    { echo "$STRING $STRING" ; cat $rand; } > $f
}



Read ()
{
    read -N100000 < "$1"
}

MathFileContentPattern ()  # POSIX
{
    local file=$1
    local pattern=$2

    Read "$file"

    case "$REPLY" in
        $pattern)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

MathFileContentRegexp () # BASH REGEXP
{
    local file=$1
    local re=$2

    Read "$file"

    [[ "$REPLY" =~ $re ]]
}

t1 ()
{
    for i in {1..100}
    do
        MathFileContentPattern $f "$string*$string"
    done
}

t2 ()
{
    for i in {1..100}
    do
        MathFileContentRegexp $f "$string*$string"
    done
}

t3 ()
{
    Read "$f"

    for i in {1..100}
    do
        [[ $REPLY =~ $RE ]]
    done
}

t4 ()
{
    for i in {1..100}
    do
        # grep(1) is almost aways the "grep -E" version, so use it in test
        grep --quiet --extended-regexp --files-with-matches "$string.*$string" $f
    done
}

t ()
{
    echo -n "# $1"
    time $1
    echo
}

trap AtExit EXIT HUP INT QUIT TERM

Setup
t t1
t t2
t t3
t t4

# End of file
