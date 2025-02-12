#! /bin/bash
#
# Q: To check file for matches: repeat read, inline match or grep(1)?
# A: Fastest is to read file once into memory and then match
#
# t1a real   0m0.049s read + bash regexp (read file once + use loop)
# t1b real   0m0.117s read + case..MATCH..esac (read file once + use loop)
# t2  real   0m0.482s read + case..MATCH..esac (separate file calls)
# t3  real   0m0.448s read + bash regexp (separate file calls)
# t4  real   0m0.404s external grep(1)
#
# Code:
#
# Study the <file>.sh for more information.
#
# read once and loop [[ str =~~ RE ]]   # t1a
# read once and loop case..MATCH..end   # t1b
# read -N<max> < file. case..MATCH..end # t2
# read -N<max> < file. [[ str =~~ RE ]] # t3
# grep RE file                          # t4
#
# Notes:
#
# Repeated reads of the same file probably utilizes
# Kernel cache to some extent. But is is still much faster
# to read file once and then apply matching.

. ./t-lib.sh ; rand=$random_file

f=$rand.t.tmp
string=abc
pattern="$string*$string"
re="$string.*$string"

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

MathFileContentRegexp () # Bash regexp
{
    local file=$1

    Read "$file"

    [[ "$REPLY" =~ $re ]]
}

t1a ()
{
    Read "$f"
    re=$string

    for i in $(seq $loop_max)
    do
        [[ $REPLY =~ $re ]]
    done
}

t1b ()
{
    Read "$f"

    for i in $(seq $loop_max)
    do
        case "$REPLY" in
            *$pattern*) ;;
        esac
    done
}

t2()
{
    for i in $(seq $loop_max)
    do
        MathFileContentPattern $f
    done
}

t3()
{
    for i in $(seq $loop_max)
    do
        MathFileContentRegexp $f
    done
}

t4()
{
    for i in $(seq $loop_max)
    do
        # grep(1) is almost aways the "grep -E" version, so use it in test
        grep --quiet --extended-regexp --files-with-matches "$re" $f
    done
}

trap AtExit EXIT HUP INT QUIT TERM

Setup
t t1a
t t1b
t t2
t t3
t t4

# End of file
