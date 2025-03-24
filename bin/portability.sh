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

# Forward decalarations for shellcheck(1)
# Defined in t-lib.sh
TMPBASE=""
VERBOSE=""

# ignore follow
# shellcheck disable=SC1091

. "$pwd/t-lib.sh"   # Common library

SHELL_LIST_DEFAULT="\
sh,\
dash,\
posh,\
busybox ash,\
mksh,\
ksh,\
bash,\
zsh\
"

SHELL_LIST_DEFAULT_DASH="\
dash,\
posh,\
busybox ash,\
mksh,\
ksh,\
bash,\
zsh\
"

SHELL_LIST=$SHELL_LIST_DEFAULT

if IsCommandExist readlink ; then
    # In Linux, sh may be symlink to dash
    # No need to test sh

    if [ "$(readlink /bin/sh)" = "dash" ]; then
        SHELL_LIST=$SHELL_LIST_DEFAULT_DASH
    fi
fi

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
    $program <x-* files>

OPTIONS
    -s, --shell SHELL[,SHELL...}
        List of shell to check for support in x-*
        portability test FILES

    -v, --verbose
        Display verbose messages.

    -h, --help
        Display help.

DESCRIPTION
    Compose matrix of support features for each shell listed
    in --shell options.

    If no --shell options is used, try testing known shells.

EXAMPLES
    $program x-*
    $program --shell dash,mksh x-*"

    exit 0
}

ShellVersion ()
{
    sh=$1

    # dash: unfortunately the version number is not compiled in

    case $sh in
        *busybox*)
            # BusyBox v1.37.0 (Debian 1:1.37.0-4) multi-call binary.
            busybox --help 2>&1 | ${AWK:-awk} '
            /^BusyBox v[0-9]+\./ {
                sub("^BusyBox +v?", "")
                print $1
                exit
            }'
            ;;
        *posh*)
            $sh -c 'echo $POSH_VERSION'
            ;;
        *mksh*)
            # @(#)MIRBSD KSH R59 2024/07/26 +Debian
            $sh -c 'echo $KSH_VERSION' | ${AWK:-awk} '
            /2[0-2][0-9][0-9]/ {
                gsub("/", "-")
                print $3 " " $4
                exit
            }'
            ;;
        ksh | ksh93*)
            # ... (AT&T Research) 93u+m/1.0.10 2024-08-01
            $sh --version 2>&1 | ${AWK:-awk} '
            /AT.T Research. +[0-9]+/ {
                print $(NF -1) " " $(NF)
                exit
            }'
            ;;
        *bash*)
            # GNU bash, version 5.2.37(1)-release ...
            $sh --version 2>&1 | ${AWK:-awk} '
            /^GNU bash.* +[0-9]/ {
                $0 = $4
                sub("[(].+$", "")
                print
                exit
            }'
            ;;
        *zsh*)
            # zsh 5.9 (x86_64-debian-linux-gnu)
            $sh --version 2>&1 | ${AWK:-awk} '
            /^zsh +[0-9]/ {
                print $2
                exit
            }'
            ;;
    esac
}

ResultsData ()
{
    separator=$1
    list=$2
    lsep=$3

    shift
    shift
    shift

    # ignore expand... single quotes
    # shellcheck disable=SC2016

    ${AWK:-awk} -F"$separator" \
    '
    function Header (fmt)
    {
        printf(fmt, "")

        for (i = 2; i <= NF; i++)
        {
            if (i < NF)
                printf("%02d ", i - 1)
            else
                printf("%02d\n", i - 1)
        }
    }

    {
        fmt="%-40s"

        if (!header)
        {
            Header(fmt)
            header="done"
        }

        # Results

        desc = $1
        printf(fmt, desc)

        for (i = 2; i <= NF; i++)
        {
            if (i < NF)
                printf("%2s ", $(i))
            else
                printf("%2s\n", $(i))
        }
    }
    ' \
    list="$list" \
    sep="$lsep" \
    "${1:-}"
}

Line ()
{
    max=$1
    i=0

    while [ "$i" -lt "$max" ]
    do
        printf "-"
        i=$((i + 1))
    done

    printf "\n"
}

ResultsShellInfo ()
{
    list=$1
    sep=$2

    Line 60

    saved=$IFS
    IFS="$sep"
    i=1

    for sh in $list
    do
        version="$(ShellVersion $sh)"

        if [ "$version" ]; then
            printf "%02d %s %s\n" "$i" "$sh" "$version"
        else
            printf "%02d %s\n" "$i" "$sh"
        fi

        i=$((i + 1))
    done

    IFS=$saved

    Line 60
}

Description ()
{
    ${AWK:-awk} '
        /^# Short: / {
            sub("^# Short: +", "")
            sub(" +$", "");
            print
            exit
        }

    ' "${@:-/dev/null}"
}

RunCheck ()
{
    shlist=$1
    shift

    sep="@"
    results="$TMPBASE.results"
    saved=$IFS
    IFS=", "

    for file in "$@"
    do

        desc=$(Description "$file")
        shresult=""

        for shell in $shlist
        do
            result="-"

            if $shell "$file" > /dev/null 2>&1; then
                result="+"
            fi

            if [ "$shresult" ]; then
                shresult="$shresult$sep$result"
            else
                shresult=$result
            fi
        done

        echo "$desc$sep$shresult" >> "$results"
    done

    IFS=$saved

    ResultsData "$sep" "$SHELL_LIST" "," "$results"
    ResultsShellInfo "$SHELL_LIST" ","
}

Main ()
{
    SetupTrapAtExit

    while :
    do
        # Unused, but useful during debug
        # shellcheck disable=SC2034
        dummy="OPT: ${1:-}"

        case "${1:-}" in
            -s | --shell)
                shift
                [ "$1" ] || Die "ERROR: missing --shell ARG"

                SHELL_LIST=$1
                shift
                ;;
            -v | --verbose)

                # not unused, see t-lib.sh
                # shellcheck disable=SC2034

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
        Die "ERROR: missing file <portability test case>. See --help."
    fi

    filelist=""

    for file in "$@"
    do
        if [ ! -f "$file" ]; then
            IsVerbose && Warn "WARN: ignore, no file: $file"
            continue
        fi

        filelist="$filelist $file"
    done

    shlist=""
    saved=$IFS
    IFS=", "

    for shell in $SHELL_LIST
    do
        sh=$shell
        sh=${sh%% *}  # leave first word

        if ! IsCommandExist "$sh" ; then
            Verbose "WARN: not exists: $sh"
            continue
        fi

        if [ "$shlist" ]; then
            shlist="$shlist,$shell"
        else
            shlist="$shell"
        fi
    done

    IFS=$saved

    # ignore quotes
    # shellcheck disable=SC2086

    RunCheck "$shlist" $filelist
}

Main "${@:-}"

# End of file
