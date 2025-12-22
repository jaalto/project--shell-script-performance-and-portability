#! /usr/bin/env bash
#
# Q: var=$(printf...) vs Bash printf -v var
# A: It is about 10x faster to use Bash specific -v option to assign value
#
#     t1 real  0.035 Dash var=$(printf ...)
#     t2 real  0.003 Bash print -v ...
#
# Code:
#
#     t1  var=$(printf "%s" "abc")
#     t2  printf -v var "%s" "abc"
#
# Notes:
#
#     ./run.sh --shell dash,ksh,bash ./t-variable-assignment-printf-bash.sh
#
#
#

. ./t-lib.sh ; f=$random_file

t1 ()
{
    for i in $(seq $loop_max)
    do
        var=$(printf "%s" "abc")
    done
}

t2 ()
{
    for i in $(seq $loop_max)
    do
        printf -v var "%s" "abc"
    done
}

t="\
:t t1
:t t2  IsFeaturePrintfOptionV
"

if [ "$source" ]; then
     :
elif [ "$run" ]; then
    "$@"
else
    RunTests "$t" "$@"
fi

# End of file
