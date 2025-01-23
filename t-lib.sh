#  -*- mode: sh; -*-
#
# This is not a script but a library.
#
# Synopsis: source <file>

rand=t.random.numbers.tmp  # create test file

if [ ! -f "$rand" ]; then
    n=10000   # 10 000 numbers
    perl -e "print int(rand(2**14-1)) . qq(\n) for 1..$n" > "$rand"
fi

unset n

# End of file
