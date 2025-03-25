#! /bin/bash
# Short: (( ... ))
# Desc: Test support for expression (( .. ))

((i++))
[ "$i" = "1" ]

