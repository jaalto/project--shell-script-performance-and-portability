#  -*- mode: sh; -*-
#
#   t-lib.sh - Liibrary of common shell functions for testing.
#
#   Copyright
#
#       Copyright (C) 2024-2025 Jari Aalto
#
#   License
#
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#       GNU General Public License for more details.
#
#       You should have received a copy of the GNU General Public License
#       along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# Description
#
#       This is a library. Common utilities.
#
# Usage
#
#       . <file>

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
        shuf --head-count=200000 /usr/share/dict/words |
        awk '
            BEGIN {
                total_size = 0;
            }

            {
                if (length(line) + length($0) + 1 <= 80)
                {
                    if (length(line) > 0)
                        line = line " " $0;
                    else
                        line = $0;
                }
                else
                {
                    print line;
                    total_size += length(line) + 1;
                    line = $0;
                }
            }

            END {
                if (length(line) > 0)
                {
                    print line;
                    total_size += length(line) + 1;
                }
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
        local timeformat=$TIMEFORMAT # save

        TIMEFORMAT="real %3R  user %3U  sys %3S"

        printf "# %-15s" "$1"
        time "$@"

        TIMEFORMAT=$timeformat  # restore
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
