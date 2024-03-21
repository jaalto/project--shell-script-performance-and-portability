#! /bin/bash
# source <file>

rand=t.random.numbers.tmp

if [ ! -f $f ]; then
    n=10000   # 10 000 numbers
    perl -e "print int(rand(2**14-1)) . qq(\n) for 1..$n" > $rand
fi

# End of file
