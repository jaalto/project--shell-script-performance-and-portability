#  -*- mode: sh; -*-
#
# This is not a script but a library.
#
# Synopsis: source <file>

random_file_count=${random_file_count:-10000}
random_file={random_file:-t.random.numbers.tmp}  # create random number test file

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
