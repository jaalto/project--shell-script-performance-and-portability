#! /usr/bin/env bash
#
# Q: Extract /path/file.txt to components: parameter expansion vs ´basename` etc.
# A: It is 10-40x faster to use in memory parameter expansion where possible
# priority: 10
#
#     t1aBase real 0.007  parameter expansion
#     t1bBase real 0.298  basename
#
#     t2aDir  real 0.007  parameter expansion
#     t2bDir  real 0.282  dirname
#
#     t3aExt  real 0.004  parameter expansion
#     t3bExt  real 0.338  cut with Bash HERE STRING
#     t3bExt  real 0.336  cut
#     t3cExt  real 0.411  awk
#     t3dExt  real 0.425  sed
#
# Code:
#
#     t1aBase  ${str##*/}
#     t1bBase  basename "$str"
#
#     t2aDir   ${str%/*}
#     t2bDir   dirname "$str"
#
#     t3aExt   ${str#*.}
#     t3bExt   cut --delimiter="." --fields=2,3 <<< "$str"
#     t3cExt   echo "$str" | cut --delimiter="." --fields=2,3
#     t3dExt   awk -v s="$str" 'BEGIN{$0 = s; sub("^[^.]+.", ""); print; exit}'
#     t3eExt   echo "$str" | sed --regexp-extended 's/^[^.]+//'
#
# Notes:
#
# It is obvious that doing everything in memory
# using POSIX parameter expansion is very
# fast. Seeing the measurements, and just how expensive it is,
# reminds us to utilize the possibilities of
# [parameter expansion](https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameter-Expansion)
# more effectively in shell scripts.
#
# It's not surprising that `echo "$str" | cut`
# perform practically the same as Bash HERE
# STRINGS in `sut <<< "$str"` use pipes under
# the hood in lastest Bash versions. See
# version 5.1 and section "c" in
# https://github.com/bminor/bash/blob/master/CHANGES
#
# **Notes**
#
# Please note that you have to run the test
# set multiple times to get an idea of relative
# positions. The milliseconds vary a lot from
# run to run. The overall picture is that heavier
# tools `awk` is latert and `sed' remains last.
#
# In the tests, we assume that directory names
# do not contain the dot (`.`) characters.
# Therefore the tests do not aim to present generic
# solutions to expand all paths like:
#
#     /path/project.git/README.txt

. ./t-lib.sh ; f=$random_file

str="/tmp/filename.txt.gz"

t1aBase ()
{
    for i in $(seq $loop_max)
    do
        item=${str##*/}  # From beg, delete up till last "/"
    done
}

t1bBase ()
{
    for i in $(seq $loop_max)
    do
        item=$(basename "$str")
    done
}

t2aDir ()
{
    for i in $(seq $loop_max)
    do
        item=${str%/*}  # From end, Delete up till first "/"
    done
}

t2bDir ()
{
    for i in $(seq $loop_max)
    do
        item=$(dirname "$str")
    done
}

t3aExt ()
{
    for i in $(seq $loop_max)
    do
        item=${str#*.}  # Delete up till first "."
    done
}

# Hide test case from other Shells that
t3bExt () { : ; } # stub

cat << 'EOF' > t.bash
t3bExt ()
{
    for i in $(seq $loop_max)
    do
        item=$(cut --delimiter="." --fields=2,3 <<< "$str")
    done
}
EOF

IsShellBash && . ./t.bash

t3cExt ()
{
    for i in $(seq $loop_max)
    do
        item=$(echo "$str" | cut --delimiter="." --fields=2,3)
    done
}

t3dExt ()
{
    for i in $(seq $loop_max)
    do
        item=$($AWK -v s="$str" 'BEGIN{$0 = s; sub("^[^.]+.", ""); print; exit}')
    done
}

t3eExt ()
{
    for i in $(seq $loop_max)
    do
        item=$(echo "$str" | sed --regexp-extended 's/^[^.]+//')
    done
}

t="\
:t t1aBase
:t t1bBase
:t t2aDir
:t t2bDir
:t t3aExt
:t t3bExt IsFeatureHereString
:t t3cExt
:t t3dExt IsCommandGnuAwk
:t t3eExt
"

RunTests "$t" "$@"

rm --force t.bash

# End of file
