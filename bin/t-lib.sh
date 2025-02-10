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

RandomWordsGibberish ()
{
    # - File SIZE containing Random words.
    # - Limit output to column 80.
    # - Separate words by spaces.

    base64 --decode /dev/urandom |
        tr --complement --delete 'a-zA-Z0-9 ' |
        fold --width=80 |
        head --bytes="${1:-100k}"
}

RandomWordsDictionary ()
{
    if [ ! -e /usr/share/dict/words ]; then
        Die "ERROR: missing word dict. Debian: apt-get install wamerican"
    else
        shuf --head-count=20000 /usr/share/dict/words |
        awk '
        {
            if (length(line) + length($0) + 1 <= 80)
            {
                if (length(line) > 0)
                    line = line " " $0
                else
                    line = $0
            } else
            {
                print line
                line = $0
            }

            if (length(line) >= 80) {
                print line
                line = ""
            }
        }

        END {
            if (line)
                print line
        }' |
        head --bytes=${1:-100k}
    fi
}

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
    if [ "$BASH_VERSION" ]; then
        _TIMEFORMAT=$TIMEFORMAT # save

        TIMEFORMAT="real %3R  user %3U  sys %3S"

        printf "# %-15s" "$1"
        time "$@"

        TIMEFORMAT=$_TIMEFORMAT  # restore
    else
        printf "# $1"
        (time date) 2>&1 | paste -sd " "
        echo
    fi
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
