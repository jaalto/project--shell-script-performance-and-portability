#! /usr/bin/env bash
#
# Q: To process lines: `readarray` vs `while read < file`
# A: It is about 2x faster to use `readarray`
# priority: 6
#
#     t1  real 0m0.037s t1  mapfile + for
#     t2a real 0m0.036s t2a readarray + for
#     t2b real 0m0.081s t2b readarray + for ((i++))
#     t3  real 0m0.085s t3  while read < file
#
# Code:
#
#     t1  mapfile -t array < file   ; for <array> ...
#     t1a readarray -t array < file ; for i in <array> ...
#     t1b readarray -t array < file ; for ((i... <array> ...
#     t1  while read ... done < file
#
# Notes:
#
# In Bash, the `readarray` built-in is a synonym for `mapfile`,
# so they should behave equally.

. ./t-lib.sh ; f=$random_file

# Hide from other shells
t1 () { : ; } # stub
t2a () { : ; } # stub
t2b () { : ; } # stub

cat << 'EOF' > t.bash
t1 ()
{
    array=()

    mapfile -t array < $f

    for i in "${array[@]}"
    do
        i=$i
    done
}

t2a ()
{
    array=()

    readarray -t array < $f

    for i in "${array[@]}"
    do
        i=$i
    done
}

t2b ()
{
    array=()

    readarray -t array < $f

    for ((i = 0; i < ${#array[@]}; i++))
    do
        item=${array[i]}
    done
}
EOF

IsShellBash && . ./t.bash
rm --force t.bash

t3 ()
{
    while read -r i
    do
        i=$i
    done < $f
}

t="\
:t t1  IsShellBash
:t t2a IsShellBash
:t t2b IsShellBash
:t t3
"

RunTests "$t" "$@"

# End of file
