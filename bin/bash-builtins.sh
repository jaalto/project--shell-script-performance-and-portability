#! /bin/bash
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

# Prevent call 'sh <program>' (sh, mksh, ksh ...)

if [ ! "$BASH_VERSION" ]; then
    echo "FATAL: $0 can only be run under bash" >&2
    exit 1
fi

set -o errexit # Exit on error
set -o nounset # Treat unused variables as errors

PROGRAM=${0##*/}
pwd=$(cd "$(dirname "$0")" && pwd)

# Forward decalarations for shellcheck(1)
# Defined in t-lib.sh

# ignore unused
# shellcheck disable=SC2034
TMPBASE=""
# shellcheck disable=SC2034
VERBOSE=""

AtExit () { :; }    # Clear. See t-lib.sh

# ignore follow
# shellcheck disable=SC1091
. "$pwd/t-lib.sh"   # Common library

Help ()
{
    echo "\
SYNOPSIS
    $PROGRAM [options]

OPTIONS
    -h, --help
        Display help.

DESCRIPTION
    List commands that are shell built-ins."
    exit 0
}

Builtins ()
{
    local cmd variants top

    for cmd in $(compgen -b)
    do
        type -P "$cmd" >/dev/null || continue

        variants=$(type -a "$cmd")
        top=$(command -V "$cmd")

        echo "${variants/$top/$top <--}"
        echo
    done
}

Main ()
{
    SetupTrapAtExit

    local dummy

    while :
    do
        # Unused, but useful during debug
        # shellcheck disable=SC2034
        dummy="OPT: ${1:-}"

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

    Builtins
}

Main "${@:-}"

# End of file
