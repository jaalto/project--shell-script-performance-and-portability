#! /bin/bash
#
# Q: Is "test -s" for size useful before reading a file?
# A: yes, much faster that way
#
# real    0m0.103s $(< file)
# real    0m0.002s [ -s file] && $(< file)

f=t.empty
: > $f

t1 ()
{
    for i in {1..100}
    do
        val=$(< $f)
    done
}

t2 ()
{
    for i in {1..100}
    do
        [ -s $f ] && val=$(< $f)
    done
}

t ()
{
    echo -n "# $1"
    time $1
    echo
}

t t1
t t2

rm -f $f

# End of file
