#! /usr/bin/env bash
#
# Q: The classic: `echo` vs `printf`
# A: No notable difference
# priority: 0
#
#     t1 real 0m0.272s echo
#     t2 real 0m0.278s printf

. ./t-lib.sh ; f=$random_file

t1 ()
{
    while read -r line
    do
        echo "$line" > /dev/null
    done < $f
}

t2 ()
{
    while read -r line
    do
        printf "%s\n" "$line" > /dev/null
    done < $f
}

t="\
:t t1
:t t2
"

if [ "$source" ]; then
     :
elif [ "$run" ]; then
    "$@"
else
    RunTests "$t" "$@"
fi

# End of file
