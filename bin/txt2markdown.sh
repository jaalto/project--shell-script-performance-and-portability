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
#
#       Convert result text file into markdown format.
#
#       This is not a general utility but a
#       specific program to the project.

set -o errexit # Exit on error
set -o nounset # Treat unused variables as errors

pwd=$(cd "$(dirname "$0")" && pwd)

# ignore follow
# shellcheck disable=SC1091

. "$pwd/t-lib.sh"

Convert ()
{
    local file=$1

    awk '
        /FILE:/ {
            sub("FILE: *", "")
            file = $0

            printf("\n# %s\n", file)
            next
        }

        /[#]!/ {
            next
        }

        /[#]/ {
            sub("^# ?", "")
        }

        /^Q:/ {
            printf("**%s**<br/>\n", $0)
            next
        }

        /^A:/ {
            printf("*%s*<br/>\n", $0)
            next
        }

        /^priority:/ {
            printf("_%s_\n", $0)
            next
        }

        /(Notes|Code):/ {
            sub(":", "")
            printf("## %s\n", $0)
            next
        }

        {
            print
        }

    ' "$file"
}

Main ()
{
    local file

    for file in "$@"
    do
        if [ ! -f "$file" ]; then
            Warn "WARN: no file: $file"
            continue
        fi

        Convert "$file"
    done
}

Main "$@"

# End of file
