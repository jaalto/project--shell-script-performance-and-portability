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
# Description
#
#       Run all test cases
#
# Synopsis
#
#       ./run-all.sh [<comma separated list of shells>]
#
# Examples
#
#       ./run-all.sh dash,ksh93,bash
#       ./run-all.sh > results.txt  # same as above

set -o errexit   # Exit on error
set -o nounset   # Treat unused variables as errors

LIB="t-lib.sh"

. "./$LIB"

shells=${1:-dash,ksh93,bash}

{
    # Disable. Parallel not used.
    # The 'time' results are not displayed properly

    if [ "" ] && IsCommandParallel; then
        ${test:+echo} "$PARALLEL" --keep-order --quote \
            ./run.sh --shell "$shells" ::: \
            $(ls ./t-*.sh | grep -v "$LIB")
    else
        ${test:+echo} ./run.sh --shell "$shells" $(ls ./t-*.sh | grep -v "$LIB")
    fi

} 2>&1

# End of file
