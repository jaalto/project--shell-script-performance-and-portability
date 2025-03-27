#! /usr/bin/env bash
#
# Q: Match string by pattern: Bash vs case..esac
# A: No noticeable difference, both are extremely fast
# priority: 0
#
#     t1 real 0m0.002s Bash
#     t2 real 0m0.003s case..esac
#
# Code:
#
#     t1 [[ $str == $pattern ]]
#     t2 case... $pattern) ... esac
#
# Notes:
#
#   Bash's version is much more compact.

. ./t-lib.sh ; f=$random_file

str="abcdef"
pattern="*cd*"

# Hide from other shells
t1 () { : ; } # stub

cat << 'EOF' > t.bash
t1 () # Bash, Ksh
{
    for i in $(seq $loop_max)
    do
        [[ $str == $pattern ]]
    done
}
EOF

IsShellModern && . ./t.bash
rm --force t.bash

t2 () # POSIX
{
    for i in $(seq $loop_max)
    do
        case $string in
            $pattern)
                true
                ;;
            *)
                false
                ;;
        esac
    done
}

t="\
:t t1 IsShellModern
:t t2
"

[ "$source" ] || RunTests "$t" "$@"

# End of file
