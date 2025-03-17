#! /bin/bash
#
# Q: What is the fastest way to get newest file in a directory
# A: Use find + filters. find + awk would be tad faster but more complex.
# priority: 3
#
#     t1 real 0m0.417s   find + awk
#     t2 real 0m0.523s   find + sort + head + cut
#     t3 real 0m0.575s   find + sort + sed
#
#     t4 real 0m0.382s   stat (not a generic solution)
#     t5 real 0m0.330s   ls -t (not a generic solution)
#
# Code:
#
# See the test code for more information. Overview:
#
#     t1 find -maxdepth 1 -type f ... | awk '<complex code>'
#     t2 find -maxdepth 1 -type f | sort -r | head -1 | cut ...
#     t3 find -maxdepth 1 -type f | sort -r | sed ...
#     t4 stat ... | sort -r | sed ...
#     t5 ls --sort=time | head -1
#
# Notes:
#
# Interestingly `head` and `cut` combined was
# faster than `sed`.
#
# Commads `ls` and `stat` can't tell files from
# directories, so they are not usable if a
# directory contains both.

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

t1 ()
{
    for i in $(seq $loop_max)
    do
        find . -maxdepth 1 -type f -printf "%T@ %p\n" |
        $AWK '
            {
               if ($1 > recent)
               {
                   recent = $1
                   file = $2
               }
            }

            END {
                print file
            }
        ' > /dev/null
    done
}

t2 ()
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


t3 ()
{
    for i in $(seq $loop_max)
    do
        find $DIR -maxdepth 1 -type f -printf "%T@ %p\n" |
            sort --reverse |
            sed --regexp-extended --quiet 's,^.+ ,,; 1p; q' \
            > /dev/null
    done
}

t4 ()
{
    for i in $(seq $loop_max)
    do
        $STAT --format="%Y %n" * |
            sort --reverse |
            sed --regexp-extended --quiet 's,^.+ ,,; 1p; q' \
            > /dev/null
    done
}

t5 ()
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
