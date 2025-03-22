#! /bin/sh
# Q: Test support for binary op STRING =~ REGEXP

string="abc"
re='^a'

[[ $string =~ $re ]]


