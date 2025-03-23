#! /usr/bin/env bash
#
# Q: How to check if GLOB matches any files: arrays vs `compgen` vs `stat`
# A: `compgen` and array+glob are slightly faster than `stat`
# priority: 2
#
#     t1 real 0m0.026s   Bash compgen GLOB
#     t2 real 0m0.028s   Bash array: (GLOB)
#     t3 real 0m0.039s   stat -t GLOB
#
# Code:
#
#     t1 compgen -G "file"*
#     t2 arr=("file"*)
#     t3 stat -t "file"*
#
# Notes:
#
# Command `stat` does more work by opening each found file.

FILE="t-file-glob-bash-compgen-vs-stat.sh"

. ./t-lib.sh ; f=$random_file

file_count=${file_count:-100}

Setup ()
{
    for i in $(seq $file_count)
    do
        touch "$TMPBASE.$i"
    done
}

t1 ()
{
    for i in $(seq $loop_max)
    do
        if compgen -G "$TMPBASE"* > /dev/null; then
            dummy="glob match"
        fi
    done
}
# Hide from other shells
t2 () { : ; } # stub

cat << 'EOF' > t.bash
t2 ()
{
    for i in $(seq $loop_max)
    do
        arr=("$TMPBASE"*)

        if [ ${#arr[*]} -gt 0 ]; then
            dummy="glob match"
        fi
    done
}
EOF

IsFeatureArrays && . ./t.bash
rm --force t.bash

t3 ()
{
    for i in $(seq $loop_max)
    do
        if $STAT -t "$TMPBASE"* > /dev/null; then
            dummy="glob match"
        fi
    done
}

t="\
:t t1 IsShellBash
:t t2 IsFeatureArray
:t t3 IsCommandGnuStat
"

Setup
SetupAtExit

[ "$source" ] || RunTests "$t" "$@"

# End of file
