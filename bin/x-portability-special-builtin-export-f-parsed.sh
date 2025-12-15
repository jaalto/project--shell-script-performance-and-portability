#! /bin/sh
# Short: non-POSIX export -f (parsed ok)
# Desc: Test POSIX Special Built-in support: export with non-standard option -f causes no parse error
# Url: https://pubs.opengroup.org/onlinepubs/9799919799/utilities/V3_chap02.html#export

fn ()
{
    :
}

# Check if option '-f' is accepted / ignored during parsing the shell
# syntax

if true; then
   :
else
   export -f fn
fi

exit $?
