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
            arr[count++] = $0
        }

        ENDFILE {
            len = length(array)

            if (len)
            {
                printf("-- %s\n", FILENAME)

                for (i = 0; i < count; i++)
                {

                }
            }
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
