#  -*- mode: sh; -*-
#
# This is not a script but a library.
#
# Synopsis: source <file>

# export variables
random_file=${random_file:-t.random.numbers.tmp}  # create random number test file
loop_max=${loop_max:-100}

# private variables. Unset after this file has been read.
random_file_count=${random_file_count:-10000}

# For test loops

RandomNumbersAwk ()
{
    awk 'BEGIN {
        n = ENVIRON["n"];  # Read 'n' from environment
        srand();

        for (i = 1; i <= n; i++)
            print int(rand() * (2**14 - 1))
    }'
}

RandomNumbersPerl ()
{
    perl -e "print int(rand(2**14-1)) . qq(\n) for 1..$random_file_count"
}

RandomNumbersPython ()
{
    python3 -c "import random; print('\n'.join(str(random.randint(0, 2**14-1)) for _ in range($random_file_count)))"
}

Warn ()
{
    echo "$*" >&2
}

Die ()
{
    Warn "$*"
    exit 1
}

Verbose ()
{
    [ "$verbose" ] || return 0
    echo "$*"
}

t () # Run test
{
    _info="# %s"

    local _bash
    [ "$BASH_VERSION" ] && _bash="bash"


    _TIMEFORMAT=$TIMEFORMAT # save

    if [ "$_bash" ]; then
        TIMEFORMAT="real %3R  user %3U  sys %3S"
        _info="# %-15s"
    fi

    printf "$_info" "$1"

    time "$@"

    if [ "$_bash" ]; then
        TIMEFORMAT=$_TIMEFORMAT  # restore
    else
        echo
    fi

    unset _info _bash
}

# AWK is fastest
# 0m0.008s  awk
# 0m0.011s  perl
# 0m0.043s  python
#
# time RandomNumbersAwk > /dev/null
# time RandomNumbersPerl > /dev/null
# time RandomNumbersPython > /dev/null

if [ ! -f "$random_file" ]; then
    RandomNumbersAwk > "$random_file"
fi

unset random_file_count

# End of file
