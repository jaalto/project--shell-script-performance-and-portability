#! /bin/sh
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
        include 'dash', 'posh', 'ksh', 'mksh', 'zsh'
        'busybox ash' etc.

    -v, --verbose
        Display <test case> header before
        running the tests.

    -h, --help
        Display help.

DESCRIPTION
    Run <test case> file(s) using bash or other shell.

EXAMPLES

    # Riming results only
    $program t-test-case.sh

    # Show header + timingg
    $program --verbose t-test-case.sh

    # Check a test case with shells
    $program --shell posh,dash,ksh,bash t-test-case.sh

    # The default repeat count in <test cases>
    # can be modified by setting \$loop_max

    loop_max=500 $program t-test-case.sh"

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

    # Extract test cases in format:
    #
    #    :t <test case> <condition>

    awk '
        /^:t t/ {
            sub("^: *t +", "")
            print
        }
    ' "$1"
}

RunBash ()
{
    local dummy="RunBash()"
    local shell="${1:-}"
    local file="${2:-}"

    [ "$shell" ] || return 1

    # Run with Bash when shell does not
    # support proper time keyword

    # ignore set -e
    # shellcheck disable=SC2310

    if ! IsShellBashAvailable; then
        Die "bash not in PATH. Required for timing."
    fi

    # ignore follow
    # shellcheck disable=SC1090

    source="source-as-library" . "$file"

    RunMaybe Info

    Tests "$file" |
    while IFS=' ' read -r test precondition
    do
        # For debug
        test="$test"
        precondition="$precondition"

        if [ "$precondition" ]; then

            # ignore quotes
            # shellcheck disable=SC2086

            if ! $shell -c "source=1 . \"$LIB\" ; $precondition"
            then
                printf "# %-24s<skip>\n" "$test $precondition"
                continue
            fi
        fi

        printf "# %-24s" "$test"

        env source="source-as-library" \
            TIMEFORMAT="$TIMEFORMAT" \
            bash -c "time $shell $file $test"
    done

    RunMaybe AtExit

    # Clear
    unset -f Info AtExit
    TrapReset
}

RunFile ()
{
    local dummy="RunFile()"
    local testfile="${1:-}"
    local shlist="${2:-}"

    case $testfile in
        */*) ;;
          *) testfile="./$testfile"
             ;;
    esac

    if [ "$VERBOSE" ]; then
        Header "$testfile"

        # ignore set -e
        # shellcheck disable=SC2310
        FileInfo "$testfile" || :
    else
        Header "$testfile" "short"
    fi

    if [ ! "$shlist" ]; then
        "$testfile"  # Run <test case> as is
        return $?
    fi

    local sh=""
    local IFS=","

    for sh in $shlist
    do
        local timewithbash=""
        local bin="$sh"
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

        if [ "$timewithbash" ]; then
            RunBash "$sh" "$testfile"
        else
            $sh "$testfile"
        fi
    done
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
    local shlist=""

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
                [ "$1" ] || Die "ERROR: missing --shell ARG"
                shlist=$1
                shift
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

    for file
    do
        if [ ! -f "$file" ]; then
            IsVerbose && Warn "WARN: ignore, no file: $file"
            continue
        fi

        RunFile "$file" "$shlist"
    done
}

Main "${@:-}"

# End of file
