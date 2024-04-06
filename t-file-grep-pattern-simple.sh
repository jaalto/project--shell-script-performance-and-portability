#! /bin/bash
#
# Q: To check match in file: read vs grep?
# A: much faster to read file to memory and do a match
#
# NOTE: this is only for brief checks if FILE contain PATTERN. Not a
# substitute for real regular expressions.
#
# t1 real   0m0.183s read + case
# t2 real   0m0.184s read + bash regexp
# t3 real   0m0.396s grep

. ./t-lib.sh ; f=$rand

tmp=t.tmp
string=abc

{ echo "$string $string" ; cat $f; } > $tmp

f=$tmp

MathFileContentPattern ()  # POSIX
{
    local file=$1
    local pattern=$2

    read -N10000 < "$file"

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

    read -N10000 < "$file"

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
    for i in {1..100}
    do
        grep --quiet --files-with-matches "$string.*$string" $f
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
t t3

rm -f $tmp

# End of file
