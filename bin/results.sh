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

        /^#!/, /^$/ {
            arr[count++] = $0
        }

        ENDFILE {
            printf("FILE: %s\n", FILENAME)

            # After each file, separate next files by newline
            # Skip first file.

            for (i = 0; i < count; i++)
                print arr[i]
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
