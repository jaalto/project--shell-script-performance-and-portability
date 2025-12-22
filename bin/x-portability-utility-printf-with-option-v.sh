#! /bin/sh
# Short: non-POSIX printf -v
# Desc: Test POSIX utlitity support: printf with non-portable -v option
# Url: https://pubs.opengroup.org/onlinepubs/9799919799/utilities/printf.html

printf -v var "%s" "" 2> /dev/null
