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
#
# Extract results from test files

PROGRAM=${0##*/}
AWK=${AWK:-awk}   # GNU version

pwd=$(cd "$(dirname "$0")" && pwd)

# ignore follow
# shellcheck disable=SC1091

. "$pwd/t-lib.sh"   # Common library

Help ()
{
    echo "\
SYNOPSIS
    $PROGRAM [options] <test case> [<test case> ...]

OPTIONS
    -h, --help
        Display help.

DESCRIPTION
    Show results (extract commentatry) from <test case>."

    exit 0
}

Warn ()
{
    echo "$*" >&2
}

Die ()
{
    Warn "$PROGRAM: $*"
    exit 1
}

Result ()
{
    # ignore false positive: Expressions don't expand ...
    # shellcheck disable=SC2016

    $AWK '
        BEGINFILE {
            delete arr
            count=0
        }

        /^#!/, /^$/ {
            arr[count++] = $0
        }

        ENDFILE {
            printf("FILE: %s\n", FILENAME)

            # After each file, separate next files by newline
            # Skip first file.

            for (i = 0; i < count; i++)
                print arr[i]
        }

    ' "$@"
}

Require ()
{
    case $($AWK --version) in
        *GNU*)
            return 0
            ;;
        *)  Die "ERROR: awk in is not GNU version (alternatively set envvar AWK to GNU awk)"
            ;;
    esac
}

Main ()
{
    local dummy

    while :
    do
        # Unused, but useful during debug
        # shellcheck disable=SC2034
        dummy="OPT: $1"

        case ${1:-} in
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

    if [ ! "$1" ]; then
        Die "ERROR: missing <test case file>. See --help."
    fi

    Result "${@:-}"
}

Main "$@"

# End of file
