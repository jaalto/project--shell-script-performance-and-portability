#! /bin/sh
# Short: $((i = i + 1))
# Desc: Test support for expression $((i=i+1))

i=0
_=$((i = i + 1))

[ "$i" = "1" ]


