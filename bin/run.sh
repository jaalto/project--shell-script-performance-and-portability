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

RUN_SHELL=""

# ignore follow
# shellcheck disable=SC1091

. "$pwd/t-lib.sh"   # Common library

Help ()
{
    program=$PROGRAM

    case "$program" in
        */*) ;;
          *) program="./$program"
             ;;
    esac

    echo "\
SYNOPSIS
    $program [options] <test case> [<test case> ...]

OPTIONS
    -s, --shell SHELL
        Run <test case> file using SHELL. This can
        be 'dash', 'posh', 'ksh', 'mksh', 'zsh'
        'busybox ash' etc.

    -v, --verbose
        Display <test case> header before
        running the tests.

    -h, --help
        Display help.

DESCRIPTION
    Run <test case> file(s) using bash or other shell.

EXAMPLES
    $program t-test-case.sh
    $program --verbose t-test-case.sh
    $program --shell ksh t-test-case.sh
    $program --shell ksh --verbose t-test-case.sh

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
    dummy="RunBash()"

    # Run with Bash when shell does not
    # support proper time keyword

    # ignore set -e
    # shellcheck disable=SC2310

    if ! IsShellBashAvailable; then
        Die "bash not in PATH. Required for timing."
    fi

    # ignore follow
    # shellcheck disable=SC1090

    source="source-as-library" . "$testfile"

    RunMaybe Info

    Tests "$1" |
    while read -r test precondition
    do
        if [ "$precondition" ]; then
            if ! $precondition ; then
                printf "# %-24s<skip>\n" "$test $precondition"
                continue
            fi
        fi

        printf "# %-24s" "$test"

        env source="source-as-library" \
            TIMEFORMAT="$TIMEFORMAT" \
            bash -c "time $RUN_SHELL $1 $test"
    done

    RunMaybe AtExit

    # Clear
    unset -f Info AtExit
    TrapReset
}

RunFile ()
{
    dummy="RunFile()"
    testfile=$1
    timewithbash=$2

    case "$testfile" in
        */*) ;;
          *) testfile="./$testfile"
             ;;
    esac

    if [ "$VERBOSE" ]; then
        Header "$testfile"
        FileInfo "$testfile" || :
    else
        Header "$testfile" "short"
    fi

    if [ "$RUN_SHELL" ]; then
        echo "Run shell: $RUN_SHELL"

        if [ "$timewithbash" ]; then
            RunBash "$testfile"
        else
            $RUN_SHELL "$testfile"
        fi
    else
        "$testfile"
    fi
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
    usebash=""

    while :
    do
        # Unused, but useful during debug
        # shellcheck disable=SC2034
        dummy="OPT: ${1:-}"

        case "${1:-}" in
            -s | --shell)
                shift
                [ "$1" ] || Die "ERROR: missing --shell ARG"

                # ignore set -e
                # shellcheck disable=SC2310

                if ! ValidateTime "$1" ; then
                    usebash="use-bash-for-timing"
                fi
                RUN_SHELL=$1
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

    for file in "$@"
    do
        if [ ! -f "$file" ]; then
            IsVerbose && Warn "WARN: ignore, no file: $file"
            continue
        fi

        RunFile "$file" "$usebash"
    done
}

Main "${@:-}"

# End of file
