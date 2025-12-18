#! /bin/sh
# Run all test cases

set -o errexit   # Exit on error
set -o nounset   # Treat unused variables as errors

LIB="t-lib.sh"

. "./$LIB"

shells=${1:-dash,ksh93,bash}

{
    # Disable. Parallel not used.
    # The 'time' results are not displayed properly

    if [ "" ] && IsCommandParallel; then
        ${test:+echo} "$PARALLEL" --keep-order --quote \
            ./run.sh --shell "$shells" ::: \
            $(ls ./t-*.sh | grep -v "$LIB")
    else
        ${test:+echo} ./run.sh --shell "$shells" $(ls ./t-*.sh | grep -v "$LIB")
    fi

} 2>&1

# End of file
