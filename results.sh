#! /bin/sh
#
# Extract results from test files

PROGRAM=${0##*/}

Result ()
{
    awk '
        BEGIN {

        }

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

        ENDFILE {
            # After each file, separate next files by newline
            # Skip first file.

            if (!newline)
                newline = 1
            else
                print ""
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
