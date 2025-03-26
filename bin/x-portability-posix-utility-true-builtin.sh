#! /bin/sh
# Short: POSIX true (builtin)
# Desc: Test POSIX utlitity support: true is builtin and not /usr/bin/true
# Url: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/true.html

case $(command -v true) in
    */*) exit 1
         ;;
    *)   exit 0
         ;;
esac
