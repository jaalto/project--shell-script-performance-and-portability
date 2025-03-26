#! /usr/bin/env bash
#
# Q: To search file for matches: in memory searh vs `grep`
# A: It is about 8-10x faster to read file into memory and then do matching
# priority: 10
#
#     t1a real 0m0.049s read once + bash regexp (read file once + use loop)
#     t1b real 0m0.054s read once + case..MATCH..esac (read file once + use loop)
#     t4  real 0m0.283s grep
#     t2  real 0m0.407s read + case..MATCH..esac (separate file calls)
#     t3  real 0m0.440s read + bash regexp (separate file calls)
#
# Code:
#
# See the test code for more information. Overview:
#
#     t1a read once and loop [[ str =~~ RE ]]
#     t1b read once and loop case..MATCH..end
#     t4  grep RE file in loop
#     t2  read every time in loop. case..MATCH..end
#     t3  read every time in loop. [[ str =~~ RE ]]
#
# Notes:
#
# Repeated reads of the same file
# probably utilizes Kernel cache to some
# extent. But it is still much faster to
# read file once into memory and then
# apply matching multiple times.
#
# The `grep` command is leaps ahead of
# re-reading the file in a loop and using
# the shell’s own matching capabilities.

. ./t-lib.sh ; rand=$random_file

f=$(mktemp -t $TMPBASE.random.file.XXX)

string=abc
pattern="$string*$string"
re="$string.*$string"

Setup ()
{
    { echo "$string $string"; cat $rand; } > $f
}

Info ()
{
    echo "INFO: test file: $(ls -l $f)"
}

Read ()
{
    # Not supported by all shells:
    #   read -N$((100 * 1024)) REPLY < "$1"

    # Use POSIX
    REPLY=$(cat "$1")
}

MatchFileContentPattern ()  # POSIX
{
    Read "$1"

    case ${REPLY:-} in
        $pattern)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Hide from other shells
MatchFileContentRegexp () { : ; } # stub
t1a () { : ; } # stub

cat << 'EOF' > t.bash
MatchFileContentRegexp () # Bash regexp
{
    Read "$1"

    [[ "$REPLY" =~ $re ]]
}

t1a () # read once
{
    Read "$f"
    re=$string

    for i in $(seq $loop_max)
    do
        [[ $REPLY =~ $re ]]
    done
}
EOF

IsFeatureMatchRegexp && . ./t.bash
rm --force t.bash

t1b () # read once
{
    Read "$f"

    for i in $(seq $loop_max)
    do
        case ${REPLY:-} in
            *$pattern*) ;;
        esac
    done
}

t2 () # read every time
{
    for i in $(seq $loop_max)
    do
        # "grep -E" is the one that is typically used
        grep --quiet --extended-regexp --files-with-matches "$re" $f
    done
}

t3 () # read every time
{
    for i in $(seq $loop_max)
    do
        MatchFileContentPattern $f
    done
}

t4 () # read every time
{
    for i in $(seq $loop_max)
    do
        MatchFileContentRegexp $f
    done
}

t="\
:t t1a IsFeatureMatchRegexp
:t t1b
:t t2
:t t3
:t t4 IsFeatureMatchRegexp
"

SetupTrapAtExit
Setup

[ "$source" ] || RunTests "$t" "$@"


# End of file
