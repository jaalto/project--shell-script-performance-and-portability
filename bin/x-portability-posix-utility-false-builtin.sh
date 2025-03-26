#! /bin/sh
# Short: POSIX false (builtin)
# Desc: Test POSIX utlitity support: false is builtin and not /usr/bin/false
# Url: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/false.html

case $(command -v false) in
    */*) exit 0
         ;;
    *)   exit 1
         ;;
esac
