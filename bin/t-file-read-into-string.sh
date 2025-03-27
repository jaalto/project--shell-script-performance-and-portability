#! /usr/bin/env bash
#
# Q: To read file into string: $(< file) vs read -N vs str=$(cat file)
# A: It is about 2x faster to use $(< file)
# priority: 5
#
#     t1  real 0m0.170s $(< file)    Bash
#     t2  real 0m0.320s read -N      non-POSIX shells
#     t1  real 0m0.390s cat          POSIX

. ./t-lib.sh ; rand=$random_file

f=$rand

ReadCat () # POSIX
{
    REPLY=$(cat $f)
}

# Hide from other shells
ReadN () { : ; } # stub

cat << 'EOF' > t.bash
ReadN () # POSIX
{
    # 500 KiB memory buffer
    read -r -N$((500 * 1025)) REPLY < $f
}
EOF

IsFeatureReadOptionN && . ./t.bash
rm --force t.bash

# Hide from other shells
ReadBash () { : ; } # stub

cat << 'EOF' > t.bash
ReadBash () # Bash
{
    REPLY=$(< $f)
}
EOF

IsFeatureReadCommandSubstitution && . ./t.bash
rm --force t.bash

t1 () # read every time
{
    for i in $(seq $loop_max)
    do
        ReadBash
    done
}

t2 () # read every time
{
    for i in $(seq $loop_max)
    do
        ReadN
    done
}

t3 () # read once
{
    for i in $(seq $loop_max)
    do
        ReadCat
    done
}


t="\
:t t1 IsFeatureReadCommandSubstitution
:t t2 IsFeatureReadOptionN
:t t3
"

[ "$source" ] || RunTests "$t" "$@"

# End of file
