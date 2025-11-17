#! /bin/bash
# Short: (( ... ))
# Desc: Test support for arithmetic expression (( .. ))
# Url: https://www.gnu.org/software/bash/manual/html_node/Shell-Arithmetic.html

i=0
((i++))
[ "$i" = "1" ]

