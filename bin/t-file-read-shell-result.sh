#! /bin/bash
#
# Q: Capturing command's output: `var=$()` vs reading from a temporary file?
# A: It is about 2x faster to use `var=$()`
# priority: 8
#
#     t1 real 0m0.428s val=$(cmd)
#     t2 real 0m0.899s cmd > file; val=$(< file)

. ./t-lib.sh ; f=$random_file

f=$TMPBASE.tmp

t1 ()
{
    for i in $(seq $loop_max)
    do
        count=$(grep --count --fixed-strings "12" $f)
    done
}

t2 ()
{
    for i in $(seq $loop_max)
    do
        grep --count --fixed-strings "12" $f > $f
        count=$(< $f)
    done
}

EnableDefaultTrap

t="\
:t t1
:t t2
"

RunTests "$t" "$@"

# End of file
