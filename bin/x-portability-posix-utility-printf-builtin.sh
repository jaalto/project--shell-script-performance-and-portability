#! /bin/sh
# Short: POSIX printf (builtin)
# Desc: Test POSIX utlitity support: printf is builtin and not /usr/bin/printf
# Url: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/printf.html

case $(command -v printf) in
    */*) exit 0
         ;;
    *)   exit 1
         ;;
esac
