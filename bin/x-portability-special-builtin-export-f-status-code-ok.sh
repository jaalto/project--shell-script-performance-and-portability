#! /bin/sh
# Short: non-POSIX export -f (ignored)
# Desc: Test POSIX Special Built-in support: export with non-standard option -f accepted
# Url: https://pubs.opengroup.org/onlinepubs/9799919799/utilities/V3_chap02.html#export

fn ()
{
    :
}

# Check if option '-f' is accepted.
#
# Meaning, that you can have the option in script and not
# cause an error

export -f fn
exit $?
