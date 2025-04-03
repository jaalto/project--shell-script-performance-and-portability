#! /bin/sh
# Short: POSIX false (builtin)
# Desc: Test POSIX utlitity support: false is builtin and not /usr/bin/false
# Url: https://pubs.opengroup.org/onlinepubs/9799919799/utilities/false.html

case $(command -v false) in
    */*) exit 1
         ;;
    *)   exit 0
         ;;
esac
