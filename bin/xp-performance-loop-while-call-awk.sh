#! /bin/sh
# Short: while loop
# Desc: Measure while loop and external awk call count

timeout 1 ${1:-bash} <<'EOF' 2> /dev/null

trap 'echo "$n"; trap - EXIT TERM INT; exit' EXIT TERM INT

n=0

while :
do
    awk 1 < /dev/null
    n=$((n + 1))
done
EOF

# End of file
