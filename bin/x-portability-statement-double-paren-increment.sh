#! /bin/sh
# Short: (( ... ))
# Desc: Test support for expression (( .. ))

i=0
((i++))

[ "$i" = "1" ]

