#! /usr/bin/env bash
#
# Q: Match string by regexp: Bash `[[ s =~ re ]]` vs `expr` vs `grep`
# A: It is 100x faster to use Bash. expr is 1.3x faster than grep
# priority: 10
#
#     t1 real 0m0.002s [[ STRING =~ RE ]] Bash
#     t2 real 0m0.220s expr RE : STRING
#     t1 real 0m0.290s echo STRING | grep -E RE
#
# Code:
#
#     t1 [[ $str =~ $re ]]
#     t2 expr match ".*$str" "$re"
#     t3 echo "$str" | grep "$re"
#
# Notes:
#
#   Bash doing it all in memory, is very very
#   fast. For POSIX `sh` shells, the `expr`
#   is much faster than `grep.

. ./t-lib.sh ; f=$random_file

str="abcdef"
re="b.*e"

# Hide from other shells
# shopt is Bash only
t1 () { : ; } # stub

cat << 'EOF' > t.bash
t1 () # Bash, Ksh
{
    for i in $(seq $loop_max)
    do
        [[ $str =~ $re ]]
    done
}
EOF

IsFeatureMatchRegexp && . ./t.bash
rm --force t.bash

t2 () # POSIX
{
    for i in $(seq $loop_max)
    do
        # 1. More readable than: expr STRING : REGEXP
        # 2. Must have ".*" because expr(1) adds
        #    implicit "^" anchor

        expr match ".*$str" "$re" > /dev/null
    done
}

t3 () # POSIX
{
    for i in $(seq $loop_max)
    do
        echo "$str" | grep -E "$re" > /dev/null
    done
}

t="\
:t t1 IsFeatureMatchRegexp
:t t2
:t t3
"

[ "$source" ] || RunTests "$t" "$@"

# End of file
