#! /bin/sh
# Short: $((i++))
# Desc: Test support for expression $((i++))

i=0
_=$((i++))

[ "$i" = "1" ]
