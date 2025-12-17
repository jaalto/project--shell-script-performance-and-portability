#! /bin/sh
# Run all test cases

LIB="t-lib.sh"

. "./$LIB"

shells=${1:-dash,ksh93,bash}

{
    if IsCommandParallel; then
        ${test:+echo} "$PARALLEL" --keep-order --quote \
            ./run.sh --shell "$shells" ::: \
            $(ls ./t-*.sh | grep -v "$LIB")
    else
        ${test:+echo} ./run.sh --shell "$shells" $(ls ./t-*.sh | grep -v "$LIB")
    fi

} 2>&1

# End of file
