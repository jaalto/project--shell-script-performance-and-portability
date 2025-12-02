#! /bin/sh
# Short: non-POSIX export -f
# Desc: Test POSIX Special Built-in support: export with non-standard option -f
# Url: https://pubs.opengroup.org/onlinepubs/9799919799/utilities/V3_chap02.html#export

fn ()
{
    :
}

export -f fn

( fn )

exit $?
