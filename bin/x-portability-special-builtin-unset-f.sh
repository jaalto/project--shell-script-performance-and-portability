#! /bin/sh
# Short: POSIX unset -f
# Desc: Test POSIX Special Built-in support: unset -f to undefine a function
# Url: https://pubs.opengroup.org/onlinepubs/9799919799/utilities/V3_chap02.html#unset

fn ()
{
    :
}

unset -f fn

( fn ) 2> /dev/null

[ "$?" != "0" ]
