#! /bin/bash
# Short: $(< file)
# Desc: Read file into string using command substitution
# Url: https://www.gnu.org/software/bash/manual/bash.html#Command-Substitution

f=t.tmp
echo 1 > $f

str=$(< $f)

rm -f $f
[ "$str" = 1 ]
