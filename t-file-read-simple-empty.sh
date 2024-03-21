#! /bin/bash
#
# Q: Shoud you use "test -s" size, to check before reading file?
# A: yes
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

# End of file
