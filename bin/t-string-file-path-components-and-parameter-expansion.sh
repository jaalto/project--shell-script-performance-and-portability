#! /bin/bash
#
# Q: Extract /path/file.txt to components: parameter expansion vs ´basename` etc.
# A: It is 20-40x faster to use in memory parameter expansion where possible
# priority: 10
#
#     t1aBase real 0.007  parameter expansion
#     t1bBase real 0.298  basename
#     t2aDir  real 0.007  parameter expansion
#     t2bDir  real 0.282  dirname
#     t3aExt  real 0.004  parameter expansion
#     t3bExt  real 0.393  cut
#     t3cExt  real 0.430  awk
#     t3dExt  real 0.460  sed
#
# Code:
#
#     t1aBase  ${str##*/}
#     t1bBase  basename "$str"
#     t2aDir   ${str%/*}
#     t2bDir   dirname "$str"
#     t3aExt   ${str#*.}
#     t3bExt   echo "$str" | cut --delimiter="." --fields=2,3
#     t3cExt   awk -v s="$str" 'BEGIN{$0 = s; sub("^[^.]+.", ""); print; exit}'
#     t3dExt   echo "$str" | sed --regexp-extended 's/^[^.]+//'
#
# Notes:
#
# It is obvious that doing everything in memory is very
# fast. Seeing the measurements, and just how expensive it is,
# reminds us to utilize the possibilities of
# [parameter expansion](https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameter-Expansion)
# more effectively in shell scripts.
#
# In the tests, we assume that directory names
# do not contain the dot (`.`) character.
#
# The tests do not aim to present generic
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

t3bExt ()
{
    for i in $(seq $loop_max)
    do
        item=$(echo "$str" | cut --delimiter="." --fields=2,3)
    done
}

t3cExt2 ()
{
    for i in $(seq $loop_max)
    do
        item=$(cut --delimiter="." --fields=2,3 <<< "$str")
    done
}

t3dExt ()
{
    for i in $(seq $loop_max)
    do
        item=$(awk -v s="$str" 'BEGIN{$0 = s; sub("^[^.]+.", ""); print; exit}')
    done
}

t3eExt ()
{
    for i in $(seq $loop_max)
    do
        item=$(echo "$str" | sed --regexp-extended 's/^[^.]+//')
    done
}

t t1aBase
t t1bBase
t t2aDir
t t2bDir
t t3aExt
t t3bExt
t t3cExt
t t3dExt

# End of file
