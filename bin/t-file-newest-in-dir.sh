#! /bin/bash
#
# Q: What is the fastest way to get newest file in directory
# A: find + awk is tad faster but more complex. Use find + filters.
#
# t1 real    0m0.417s   find + awk
# t2 real    0m0.523s   find + sort + head + cut
# t3 real    0m0.575s   find + sort + sed
#
# t4 real    0m0.382s   stat (not a generic solution)
# t5 real    0m0.330s   ls -t (not a generic solution)
#
# Code:
#
# See <file>.sh for more details.
#
# find -maxdepth 1 -type f ... | awk '<complex code>'       # t1
# find -maxdepth 1 -type f | sort -r | head -1 | cut ...    # t2
# find -maxdepth 1 -type f | sort -r | sed ...              # t3
# stat ... | sort -r | sed ...                              # t4
# ls --sort=time | head -1                                  # t5
#
# Notes:
#
# awk(1) binary is smaller that sed(1)
#
# Probably small head(1) and cut(1) combined is still
# faster than sed(1) which uses regexp engine.
#
# These can't tell files from directories:
#
#   ls -t   sort by time
#   stat

. ./t-lib.sh ; f=$random_file

pwd=$(cd "$(dirname "$0")" && pwd)
max_files=${max_files:-100}
DIR=$(mktemp --directory --tmpdir="$pwd")

AtExit ()
{
    [ -d "$DIR" ] || return 0

    rm --recursive --force "$DIR/"
}

Setup ()
{
    mkdir --parents "$DIR"

    # Generate files 1h apart

    for i in $(seq $loop_max)
    do
        touch --date="-$i hours" "$DIR/$i" || exit $?
    done
}

t1()
{
    for i in $(seq $loop_max)
    do
        find . -maxdepth 1 -type f -printf "%T@ %p\n" |
        awk '
            {
               if ($1 > recent)
               {
                   recent = $1
                   file = $2
               }
            }
            END { print file }
        ' > /dev/null
    done
}

t2()
{
    for i in $(seq $loop_max)
    do
        find $DIR -maxdepth 1 -type f -printf "%T@ %p\n" |
            sort --reverse |
            head --lines=1 |
            cut --delimiter=' ' --fields=2 \
            > /dev/null
    done
}


t3()
{
    for i in $(seq $loop_max)
    do
        find $DIR -maxdepth 1 -type f -printf "%T@ %p\n" |
            sort --reverse |
            sed --regexp-extended --quiet 's,^.+ ,,; 1p; q' \
            > /dev/null
    done
}

t4()
{
    for i in $(seq $loop_max)
    do
        stat --format="%Y %n" * |
            sort --reverse |
            sed --regexp-extended --quiet 's,^.+ ,,; 1p; q' \
            > /dev/null
    done
}

t5()
{
    for i in $(seq $loop_max)
    do
        ls --sort=time | head --lines=1 > /dev/null
    done
}

trap AtExit EXIT HUP INT QUIT TERM
Setup

t t1
t t2
t t3
t t4
t t5

# End of file
