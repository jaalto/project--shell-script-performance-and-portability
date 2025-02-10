#! /bin/sh
#
# Extract results from test files

PROGRAM=${0##*/}

Result ()
{
    awk '
        BEGINFILE {
            delete arr
            count=0
        }

        /^#[[:space:]]+[QA]: / {
            if (!count)
                printf("-- %s\n", FILENAME)

            sub("^# ", "")
            print
            count++
        }
    ' "$@"
}

Main ()
{
    if [ ! "$1" ]; then
        echo "Synopsis: $PROGRAM <test file> ..."
        return 1
    fi

    Result "$@"
}

Main "$@"

# End of file
