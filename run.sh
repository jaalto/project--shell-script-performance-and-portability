#! /bin/sh

PROGRAM=${0##*/}
LINE=$(printf '%*s' "55" '' | tr ' ' '-')

FileInfo ()
{
    awk '
        /^#!/, /^$/ {
            print
        }

    ' "$1"
}

Header ()
{
    echo "-- $LINE"
    echo "-- $1"
    echo "-- $LINE"
}

Run ()
{
    Header "$1"
    FileInfo "$1"
    "./$1"
}

Main ()
{
    if [ ! "$1" ]; then
        echo "Synopsis: $PROGRAM <test file to run> ..."
        return 1
    fi

    for file in "$@"
    do
        Run "$file"
    done
}

Main "$@"

# End of file
