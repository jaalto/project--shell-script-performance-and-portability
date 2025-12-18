#! /usr/bin/env bash
#
#   Copyright
#
#       Copyright (C) 2024-2025 Jari Aalto
#
#   License
#
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#       GNU General Public License for more details.
#
#       You should have received a copy of the GNU General Public License
#       along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# Usage
#
#       See the --help option.

set -o errexit # Exit on error
set -o nounset # Treat unused variables as errors

PROGRAM=${0##*/}
pwd=$(cd "$(dirname "$0")" && pwd)

PREFIX="-- "
LINE=$(printf '%*s' "55" '' | tr ' ' '-')
TIMEFORMAT="real %3R  user %3U  sys %3S"

LIB="$pwd/t-lib.sh"

# ignore follow
# shellcheck disable=SC1090

source="source-only" . "$LIB"
SetupTrapAtExit  # clean up temporary files

Help ()
{
    program=$PROGRAM

    case $program in
        */*) ;;
          *) program="./$program"
             ;;
    esac

    echo "\
SYNOPSIS
    $program [options] <test case> [<test case> ...]

OPTIONS
    -s, --shell SHELL-LIST
        Run <test case> file using SHELL-LIST.
        The list is separated by commas. This could
        include 'dash', 'posh', 'ksh', 'mksh',
        'busybox ash' etc.

    -v, --verbose
        Display <test case> header before
        running the tests.

    -h, --help
        Display help.

DESCRIPTION
    Run <test case> file(s) using bash or other shell.

    Note: zsh shell cannot be used because it can only
    time(1) programs. It cannot time test cases that are
    shell functions.

EXAMPLES

    # Riming results only
    $program t-test-case.sh

    # Show header + timingg
    $program --verbose t-test-case.sh

    # Check a test case with shells
    $program --shell posh,dash,ksh,bash t-test-case.sh

    # The default repeat count in <test cases>
    # can be modified by setting \$loop_max

    $program --loop-max 500 t-test-case.sh"

    exit 0
}

IsShellBashAvailable ()
{
    IsCommandExist bash || return 1
}

FileInfo ()
{
    awk '
        /^#!/, /^$/ {
            print
        }

    ' "$1"
}

Header ()
{
    if [ "$1" ]; then
        echo "${PREFIX}$1"
        return
    fi

    echo "\
${PREFIX}$LINE
${PREFIX}$1
${PREFIX}$LINE"

}

Tests ()
{
    dummy="Tests()"
    unset dummy

    # Extract test cases in format:
    #
    #    :t <test case> <condition>

    ${AWK:-awk} '
        /^:t[ \t]+t/ {
            sub(/^:[ \t]*t[ \t]+/, "")
            print
        }
    ' "$1"
}

CalculateTimeEpoch ()
{
    # Calculate difference of Bash 5.x $EPOCHREALTIME

    [ "${1:-}" ] || return 1
    [ "${2:-}" ] || return 1

    local beg
    beg="$1"

    local end
    end="$2"

    local diff
    diff=$(echo "$end - $beg" | bc)

    # Format to 3 decimal places (0.000s)
    printf "%.3fs\n" "$diff"
}

CalculateTime ()
{
    # Format output of /usr/bin/time

    # ignore quotes
    # shellcheck disable=SC2016

    ${AWK:-awk} -v time="$TIME" '
    BEGIN {
        # real 0.019  user 0.010  sys 0.002
        count = split(time, arr)

        basetime_real = arr[2]
        basetime_user = arr[4]
        basetime_sys  = arr[6]
    }

    {
        real = $2 - basetime_real
        user = $4 - basetime_user
        sys  = $6 - basetime_sys

        # No negative values

        if (real < 0)
            real = 0

        if (user < 0)
            user = 0

        if (sys < 0)
            sys = 0

        printf "real %.3f  user %.3f  sys %.3f\n", real, user, sys
        exit
    }'
}

RunBash ()
{
    local dummy shell file time

    dummy="RunBash()"
    shell="${1:-}"
    file="${2:-}"

    [ "$shell" ] || return 1

    runbash_ifs="
 "

    # Run with Bash when shell does not
    # support proper 'time' keyword

    # ignore follow
    # shellcheck disable=SC1090

    loop_max=$loop_max source="source-as-library" . "$file"

    # ignore variable - TMPBASE is defined in t-lib.sh
    # shellcheck disable=SC2154

    time=$(mktemp -t "$TMPBASE.time.XXX")

    RunMaybe Info

    Tests "$file" |
    while IFS=' ' read -r test precondition
    do
        IFS=$runbash_ifs

        # For debug
        test="$test"
        precondition="$precondition"

        if [ "$precondition" ]; then
            # ignore quotes
            # shellcheck disable=SC2086

            if ! $shell -c "loop_max=$loop_max source=1 . \"$LIB\" ; $precondition"
            then
                printf "# %-25s <skip>\n" "$test $precondition"
                continue
            fi
        fi

        # TODO: could the time be accomplished
        # by using Bach EPOCHTIME?

        # GET BASELINE
        # How long it takes to read a script
        #
        # real    0m0.025s
        # user    0m0.001s
        # sys     0m0.015s

        {
            TIMEFORMAT="$TIMEFORMAT" \
            source="source-as-library" \
            bash -c "time $shell $file"
        } \
        > "$time" 2>&1

        printf "# %-26s" "$test"

        TIME=$(cat "$time")

        {
            run="run-test" \
            source="" \
            loop_max="$loop_max" \
            TIMEFORMAT="$TIMEFORMAT" \
            bash -c "time $shell $file $test"
        } \
        2>&1 | TIME="$TIME" CalculateTime

        IFS=' '
    done

    RunMaybe AtExit

    # Clear
    unset -f Info AtExit
    unset dummy shell file

    TrapReset
}

RunFile ()
{
    local dummy testfile shlist

    dummy="RunFile()"
    testfile="${1:-}"
    shlist="${2:-}"

    case $testfile in
        */*) ;;
          *) testfile="./$testfile"
             ;;
    esac

    dummy="check: VERBOSE"

    if [ "$VERBOSE" ]; then
        Header "$testfile"

        # ignore set -e
        # shellcheck disable=SC2310
        FileInfo "$testfile" || :
    else
        Header "$testfile" "short"
    fi

    dummy="check: shlist"

    if [ ! "$shlist" ]; then
        "$testfile"  # Run <test case> as is
        return $?
    fi

    local sh runfile_ifs

    runfile_ifs=$IFS
    IFS=","
    sh=""

    for sh in $shlist
    do
        IFS=$runfile_ifs

        local timewithbash bin

        timewithbash=""

        bin="$sh"
        bin="${bin%% *}"  # "busybox ash" => "busybox"

        if ! IsCommandExist "$bin"; then
            IsVerbose && Warn "WARN: not in PATH: $sh"
            continue
        fi

        # ignore set -e
        # shellcheck disable=SC2310

        if ! ValidateTime "$sh" ; then
            timewithbash="use-bash-for-timing"
        fi

        echo "Run shell: $sh"
        dummy="timewithbash: $timewithbash"

        if [ "$timewithbash" ]; then
            RunBash "$sh" "$testfile"
        else
            # ignore quotes
            # shellcheck disable=SC2086
            loop_max=$loop_max $sh "$testfile"
        fi

        IFS=","
    done

    IFS=$runfile_ifs

    unset dummy testfile shlist sh
    unset runfile_ifs timewithbash bin
}

ValidateTime ()
{
    dummy="ValidateTime()"

    # Check that time keyword can call functions.

    case $1 in
        *zsh* | *dash* | *posh* | *busybox* )
            return 1
            ;;
        *)  str=$("$1" -c "command -v time")

            case $str in
                /*) # /usr/bin/time
                    return 1
                    ;;
            esac
            ;;
    esac
}

Main ()
{
    # ignore set -e
    # shellcheck disable=SC2310

    if ! IsShellBashAvailable; then
        Die "ERROR: bash not in PATH. Required for timing."
    fi

    local dummy
    local shlist
    shlist=""

    # Reset
    unset PS1 PS2 PS3 PS4

    while :
    do
        # Unused, but useful during debug
        # shellcheck disable=SC2034
        dummy="OPT: ${1:-}"

        case ${1:-} in
            -s | --shell)
                shift
                [ "${1:-}" ] || Die "ERROR: missing --shell ARG"
                if IsMatchGlob "*zsh*" "$1"; then
                    :
                    # Die "ERROR: --shell zsh, invalid. Cannot time functions"
                fi

                shlist=$1
                shift
                ;;
            -l | --loop-max)
                loop_max=$2   # GLOBAL. Used in t-lib.sh
                shift ; shift
                ;;

            -v | --verbose)
                VERBOSE="verbose"
                shift
                ;;
            -h | --help)
                shift
                Help
                ;;
            --)
                shift
                break
                ;;
            -*)
                Warn "$PROGRAM: WARN Unknown option: $1"
                shift
                ;;
            *)
                break
                ;;
        esac
    done

    if [ ! "${1:-}" ]; then
        Die "ERROR: missing file <test case>. See --help."
    fi

    local file

    for file in "$@"
    do
        if [ ! -f "$file" ]; then
            IsVerbose && Warn "WARN: ignore, no file: $file"
            continue
        fi

        RunFile "$file" "$shlist"
    done

    unset dummy shlist file
}

Main "${@:-}"

# End of file
