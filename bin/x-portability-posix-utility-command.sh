#! /bin/sh
# Q: POSIX support: command -v, type, hash

Run ()
{
    tmp=t.tmp

    "$@" > $tmp 2>&1

    status=$?
    output=""

    [ -s $tmp ] && output=$(cat $tmp | tr -d '\n')

    [ "$output" ] && output=" $output"

    printf "# status: %-3d cmd: %s output:%s\n" $status "$*" "$output"

    rm $tmp
}

Run command -v ls
Run type ls
Run hash ls
