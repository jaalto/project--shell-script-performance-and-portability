#! /bin/sh
# Run all test cases

shells=${1:-dash,ksh93,bash}

./run.sh --shell "$shells" $(ls ./t-*.sh | grep -v lib)

# End of file
