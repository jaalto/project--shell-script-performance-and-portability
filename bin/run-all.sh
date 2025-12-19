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

set -o errexit   # Exit on error
set -o nounset   # Treat unused variables as errors

VERSION="2025.1219.0922"

pwd=$(cd "$(dirname "$0")" && pwd)
PROGRAM=${0##*/}

SHELL_DEFAULT="dash,ksh,bash"
PARALLEL="parallel"
LIB="t-lib.sh"

# ignore follow
# shellcheck disable=SC1090

source="source-only" . "$pwd/$LIB"

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
    $program [[--shell] SHELL-LIST}

OPTIONS
    -s, --shell SHELL-LIST
        Run <test case> file using SHELL-LIST.
        The list is separated by commas. This could
        include 'dash', 'posh', 'ksh', 'mksh',
        'busybox ash' etc.
        Default is: SHELL_DEFAULT

    -V, --version
        Display version, license etc. and exit.

    -h, --help
        Display help.

DESCRIPTION
    Run all test cases under --shell SHELL-LIST

EXAMPLES
    $program # use defaults
    $program dash,ksh93,bash"

    exit 0
}

Main ()
{
    local shlist
    shlist="$SHELL_DEFAULT"

    local parallel
    parallel=""


    local dummy

    while :
    do
        # Unused, but useful during debug
        # shellcheck disable=SC2034
        dummy="OPT: ${1:-}"

        case ${1:-} in
            -s | --shell)
                shift
                [ "${1:-}" ] || Die "ERROR: missing --shell ARG"
                shlist=$1
                shift
                ;;
            -V | --version)
                shift
                Version
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

    if [ "${1:-}" ]; then
        shlist="$1"
    fi

    if IsCommandParallel; then
        # Not activated.
        # The 'time' results under parallel are not
        # displayed properly
        :
    fi

    if [ "$parallel" ]; then
        # ignore quotes
        # shellcheck disable=SC2010,SC2046

        ${test:+echo} "$PARALLEL" --keep-order --quote \
            ./run.sh --shell "$shlist" ::: \
            $(ls ./t-*.sh | grep -v "$LIB")
    else
        # ignore quotes
        # shellcheck disable=SC2010,SC2046

        ${test:+echo} ./run.sh --shell "$shlist" $(ls ./t-*.sh | grep -v "$LIB")
    fi
}

{ Main "$@" ; } 2>&1

# End of file
