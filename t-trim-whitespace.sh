#! /bin/bash
#
# Q: Trim whitepace using Bash only vs sed(1)
# A: Bash is much faster; especially even with nameref
#
# real    0m0.497s sed
# real    0m0.158s Bash

s='[[:space:]]+'
S='[^[:space:]]+'

str="  this string  "

t1 ()
{
    for i in {1..100}
    do
        x=$(echo "$str" | sed -E "s,^$s*(.*$S)\s*$,\1,")
    done
}

trim ()
{
    local var=$1

    [[ $var =~ ^$s(.+)$   ]] && var=${BASH_REMATCH[1]}
    [[ $var =~ ^(.*$S)$s$ ]] && var=${BASH_REMATCH[1]}

    echo "$var"
}

t2 ()
{
    for i in {1..100}
    do
        x=$(trim "$str")
    done
}

trim_nameref ()
{
    local -n var=$1

    [[ $var =~ ^$s(.+)$   ]] && var=${BASH_REMATCH[1]}
    [[ $var =~ ^(.*$S)$s$ ]] && var=${BASH_REMATCH[1]}
}

t3 ()
{
    for i in {1..100}
    do
        x=$str
        trim_nameref x
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
t t3

# End of file
