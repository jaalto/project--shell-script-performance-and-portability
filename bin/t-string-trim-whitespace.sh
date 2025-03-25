#! /usr/bin/env bash
#
# Q: Trim whitepace using Bash RE vs `sed`
# A: It is 8x faster to use Bash, especially with fn() nameref
# priority: 10
#
#     t2 real 0m0.025s Bash fn() RE, using nameref for return value
#     t2 real 0m0.107s Bash fn() RE
#     t1 real 0m0.440s echo | sed RE
#
# Code:
#
#     t1 BashTrim var                    # fn() using nameref
#     t2 var=$(bashTrim "$str")          # fn() return by value
#     t3 var=$(echo "$str" | sed <trim>) # subshell call

. ./t-lib.sh ; f=$random_file

# Define perl style \s and \S shorthand variables
s='[[:space:]]+'
S='[^[:space:]]+'

str="  this string  "

# Hide from other shells
TrimReNameref () { : ; } # stub
cat << 'EOF' > t.bash
TrimReNameref ()
{
    local -n _retval=$1

    [[ $_retval =~ ^$s(.+)$   ]] && _retval=${BASH_REMATCH[1]}
    [[ $_retval =~ ^(.*$S)$s$ ]] && _retval=${BASH_REMATCH[1]}
}
EOF
IsShellBash && . ./t.bash
rm --force t.bash

# Hide from other shells
TrimRe () { : ; } # stub
cat << 'EOF' > t.bash
TrimRe ()
{
    var=$1

    [[ $var =~ ^$s(.+)$   ]] && var=${BASH_REMATCH[1]}
    [[ $var =~ ^(.*$S)$s$ ]] && var=${BASH_REMATCH[1]}

    echo "$var"
}
EOF
IsShellModern && . ./t.bash
rm --force t.bash

t1 ()
{
    for i in $(seq $loop_max)
    do
        item=$str
        TrimReNameref item
    done
}

t2 ()
{
    for i in $(seq $loop_max)
    do
        item=$(TrimRe "$str")
    done
}

t3 ()
{
    for i in $(seq $loop_max)
    do
        item=$(echo "$str" | ${SED:-sed} --regexp-extended "s,^$s*(.*$S)\s*$,\1,")
    done
}

t="\
:t t1 IsShellBash
:t t2 IsShellModern
:t t3
"

[ "$source" ] || RunTests "$t" "$@"

# End of file
