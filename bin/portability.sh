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

BASH_VERSION=${BASH_VERSION:-$(bash -c 'echo $BASH_VERSION' 2> /dev/null)}

WIDTH="40"
LINE_LENGTH="66"
LINE_STR=""

# Forward decalarations for shellcheck(1)
# Defined in t-lib.sh

# shellcheck disable=SC2034
TMPBASE=""
# shellcheck disable=SC2034
VERBOSE=""

AtExit () { :; }    # Clear. See t-lib.sh

# ignore follow
# shellcheck disable=SC1091

. "$pwd/t-lib.sh"   # Common library, Ksh typeset/local

SHELL_LIST_DEFAULT="\
sh,\
posh,\
dash,\
pbosh,\
busybox ash,\
mksh,\
ksh,\
bash --posix 3.2,\
bash,\
zsh\
"

SHELL_LIST_DEFAULT_DASH="\
posh,\
dash,\
pbosh,\
busybox ash,\
mksh,\
ksh,\
bash --posix 3.2,\
bash,\
zsh\
"

SHELL_LIST=$SHELL_LIST_DEFAULT

if IsCommandExist readlink ; then
    # In Linux, sh may be symlink to dash
    # No need to test sh

    case "$(readlink /bin/sh)" in
        *dash*)
            SHELL_LIST=$SHELL_LIST_DEFAULT_DASH
            ;;
    esac
fi

Help ()
{
    local program
    program="$PROGRAM"

    case ${program:-} in
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

    -w, --width SIZE
        The width SIZE of the description part
        to the left.

    -v, --verbose
        Display verbose messages.

    --help-pbosh
        Display pbosh shell install help.

    -h, --help
        Display help.

DESCRIPTION
    Compose matrix of support features for each shell listed
    in --shell options.

    If no --shell options is used, try testing known shells.

NOTES
    The 'bash --posix 3.2' runs with 'BASH_COMPAT=3.2' in effect to
    test macOS compatibility.
    https://www.gnu.org/software/bash/manual/bash.html#Shell-Compatibility-Mode

TEST FILE FORMAT
    Each test file must return true (0) or false (non-zero).
    The comment section at the beginning must include:

    #! <path to interpreter>
    # Short: <short description up to 40 characters>
    # Desc: <longer description up to 80 characters>

    <code>

    # End of file

EXAMPLES
    $program x-*
    $program --width 25 x-*
    $program --shell dash,mksh x-*"

    exit 0
}

HelpBposh ()
{
    # ignore single quote
    # shellcheck disable=SC2016

    echo 'THE PBOSH SHELL

    From schilitools, you can find the pbosh shell.
    To install locally as root:

    git clone https://codeberg.org/schilytools/schilytools.git

    cd schilytools

    for dir in libshedit libgetopt libxtermcap libschily pbosh
    do
        (cd $dir && gmake DEFLINKMODE=static GMAKE_NOWARN=true)
    done

    install -D -m 644 OBJ/x86_64-linux-gcc/man/pbosh.1 /usr/local/man/man1/pbosh.1
    install -m 755 OBJ/x86_64-linux-gcc/pbosh /usr/local/bin/'

    exit 0
}

ShellVersionDash ()
{
    # Unfortunately the version number is
    # not compiled in. Revert to package
    # manager.

    # Output:
    # ii  dash  0.5.12-12  amd64  POSIX-compliant shell

    IsCommandExist dpkg &&
        DPKG_COLORS=never PAGER=cat \
        dpkg -l dash |
        awk '/dash/ {print $3}'
}

ShellVersionMain ()
{
    local sh
    sh="${1:-}"

    case $sh in
        *dash*)
            ShellVersionDash
            ;;
        *pbosh*)
            # sh (Schily Bourne Shell) version
            # pbosh 2023/01/12 a+ (--)

            $sh --version 2>&1 |
            ${AWK:-awk} '
            /2[0-2][0-9][0-9]/ {
                gsub(/^.*pbosh +/, "")
                print
                exit
            }'
            ;;
        *posh*)
            # ignore $var in single quote
            # shellcheck disable=SC2016
            $sh -c 'echo $POSH_VERSION' 2> /dev/null
            ;;
        *mksh*)
            # @(#)MIRBSD KSH R59 2024/07/26 +Debian

            # ignore $var in single quote
            # shellcheck disable=SC2016
            $sh -c 'echo $KSH_VERSION'  2> /dev/null |
            ${AWK:-awk} '
            /2[0-2][0-9][0-9]/ {
                gsub("/", "-")
                print $3 " " $4
                exit
            }'
            ;;
        ksh | ksh93*)
            # ... (AT&T Research) 93u+m/1.0.10 2024-08-01

            # ignore single quote
            # shellcheck disable=SC2016

            $sh --version 2>&1 |
            ${AWK:-awk} '
            /AT.T Research. +[0-9]+/ {
                print $(NF -1) " " $(NF)
                exit
            }'
            ;;
        *bash*)
            # GNU bash, version 5.2.37(1)-release ...

            # ignore single quote
            # shellcheck disable=SC2016

            $sh --version 2>&1 |
            ${AWK:-awk} '
            /^GNU bash.* +[0-9]/ {
                $0 = $4
                sub(/[(].+$/, "")
                print
                exit
            }'
            ;;
        *zsh*)
            # zsh 5.9 (x86_64-debian-linux-gnu)

            # ignore single quote
            # shellcheck disable=SC2016

            $sh --version 2>&1 |
            ${AWK:-awk} '
            /^zsh +[0-9]/ {
                print $2
                exit
            }'
            ;;
        *busybox*)
            # BusyBox v1.37.0 (Debian 1:1.37.0-4) multi-call binary.

            # ignore single quote
            # shellcheck disable=SC2016

            busybox --help 2>&1 |
            ${AWK:-awk} '
            /^BusyBox v[0-9]+\./ {
                sub(/^BusyBox +v?/, "")
                print $1
                exit
            }'
            ;;
    esac

    unset sh
}

ResultsData ()
{
    local separator list lsep

    separator="${1:-}"
    list="${2:-}"
    lsep="${3:-}"

    shift $#

    [ "$lsep" ] || return 1

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
        fmt="%-" width "s"

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
    width="$WIDTH" \
    "${1:-}"

    unset separator list lsep
}

Line ()
{
    local max sh i

    max="${1:-}"
    ch="${2:-"-"}"
    i=0

    [ "$max" ] || return 1

    while [ "$i" -lt "$max" ]
    do
        printf "%s" "$ch"
        i=$((i + 1))
    done

    unset max ch i
    printf "\n"
}

LineStraight ()
{
    Line "$LINE_LENGTH"
}

ResultsShellInfo ()
{
    local list sep

    list="${1:-}"
    sep="${2:-}"

    [ "$sep" ] || return 1

    echo "$LINE_STR"

    local sh i ifs

    i=1
    ifs="$IFS"
    IFS="$sep"

    for sh in $list
    do
        version="$(ShellVersionMain "$sh")"

        if [ "$version" ]; then
            printf "%02d %s %s\n" "$i" "$sh" "$version"
        else
            printf "%02d %s\n" "$i" "$sh"
        fi

        i=$((i + 1))
    done

    IFS="$ifs"

    unset list sep sh i ifs
    echo "$LINE_STR"
}

Description ()
{
    ${AWK:-awk} '
        /^# Short: / {
            sub(/^# Short:[ \t]+/, "")
            sub(/[ \t]+$/, "");
            print
            exit
        }

    ' "${@:-/dev/null}"
}

RunShells ()
{
    local compat usecompat

    compat="BASH_COMPAT=3.2" # default
    usecompat=""

    if IsShellBashFeatureCompat; then
        usecompat="use-bash-compat"
    fi

    local shell result env ifs shresult ifs

    shresult=""
    saved="$IFS"
    IFS=","

    for shell in $shlist
    do
        shell=$shell   # for debug
        result="-"
        env=""

        case $shell in
            bash*--posix*)
                if [ "$usecompat" ] ; then
                    env="$compat"
                    ifs="$IFS"
                    IFS="$saved"

                    # ignore quotes
                    # shellcheck disable=SC2086

                    set -- $shell

                    case ${3:-} in
                        [2-9]*)
                            env="BASH_COMPAT=$3"
                            shell="$1 $2"
                            ;;
                    esac

                    IFS="$ifs"
                fi
                ;;
        esac

        # eval is needed because shell would be
        # "busybox ash", which must be broken apart
        # to separate words.

        # ignore quotes
        # shellcheck disable=SC2086

        if eval $env $shell "$file" > /dev/null 2>&1
        then
            result="+"
        fi

        if [ "$shresult" ]; then
            shresult="$shresult$sep$result"
        else
            shresult=$result
        fi
    done

    IFS="$saved"
    unset shell result env ifs shresult ifs saved

    echo "$shresult"
}

RunCheck ()
{
    local shlist
    shlist="${1:-}"

    [ "$shlist" ] || return 1

    shift

    local sep
    local results

    sep="@"
    results="$(mktemp -t "$TMPBASE.results.XXX")"

    local file

    for file # Implicit "$@"
    do
        desc=$(Description "$file")
        shresult=$(RunShells "$shlist")

        echo "$desc$sep$shresult" >> "$results"
    done

    IFS=$saved

    echo "$LINE_STR"

    ResultsData "$sep" "$SHELL_LIST" "," "$results"
    ResultsShellInfo "$SHELL_LIST" ","
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
            -s | --shell)
                shift
                [ "${1:-}" ] || Die "ERROR: missing --shell ARG"

                SHELL_LIST="$1"
                shift
                ;;
            -w | --width)
                DieOption "--width" "$2"
                DieOptionNotNumber "--width" "$2"
                WIDTH=$2
                shift ; shift
                ;;
            -v | --verbose)
                # not unused, see t-lib.sh
                # shellcheck disable=SC2034
                VERBOSE="verbose"
                shift
                ;;
            --help-pbosh)
                shift
                HelpBposh
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

    local filelist
    filelist=""

    LINE_STR=$(LineStraight)

    for file # Implicit "$@"
    do
        if [ ! -f "$file" ]; then
            IsVerbose && Warn "WARN: ignore, no file: $file"
            continue
        fi

        filelist="$filelist $file"
    done

    local shell
    local shlist
    local saved

    shlist=""
    saved="$IFS"

    IFS=","

    # ignore quotes, unused
    # shellcheck disable=SC2086,SC2034

    dummy="shellist: $SHELL_LIST"

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
