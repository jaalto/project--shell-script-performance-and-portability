#  -*- mode: sh; -*-
#
#   t-lib.sh - Library of common shell functions for testing.
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
#       Source this file with command:
#
#           . <file>
#
# Requirements
#
#       Requires GNU utilities first in PATH. Those of sed,
#       awk, cut, head, tr etc. Used GNU --long options for
#       calling commands (code maintenance).
#
# Description
#
#       This is a library. Common utilities. When sourced, it
#       will create the following test file to be used by
#       <test cases>:
#
#           t.random.numbers.tmp
#
#       Global variables used:
#
#           $VERBOSE in Verbose()
#
#       Exported variables:
#
#           $PROGRAM
#           $TMPBASE
#           $DICTIONARY_FILE
#           $AWK
#           $BASE64
#           $FOLD
#           $HEAD
#           $PARALLEL
#           $PERL
#           $SED
#           $SHUF
#           $STAT
#           $TR
#
#           $loop_max
#           $random_file
#           $random_file_count
#
# Notes
#
#   To support ksh, the 'local' keyword
#   is written on its own line.
#   Sometimes, the code is also
#   accompanied by an additional 'unset
#   <var>' command, just in case.

# -- ------------------------------------
# -- Exported variables
# -- ------------------------------------

PROGRAM=$0
TMPBASE=${LOGNAME:-$USER}.$$.test

VERBOSE=""
T_LIB_CACHE_GNU=""

# -- ------------------------------------
# -- Public. User settable env variables
# -- ------------------------------------

# create random number test file
random_file=${random_file:-t.random.numbers.tmp}
random_file_count=${random_file_count:-10000}
loop_max=${loop_max:-100}

AWK=${AWK:-"awk"}
BASE64=${BASE64:-"base64"}
FOLD=${FOLD:-"fold"}
HEAD=${HEAD:-"head"}
PARALLEL=${PARALLEL:-"parallel"}
PERL=${PERL:-"perl"}
PYTHON=${PYTHON:-"python3"}
RM=${RM:-"rm"}
SED=${SED:-"sed"}
SHUF=${SHUF:-"shuf"}
STAT=${STAT:-"stat"} # Must be GNU version
TR=${TR:-"tr"}

DICTIONARY_DEFAULT="/usr/share/dict/words"
DICTIONARY_FILE=${DICTIONARY_FILE:-$DICTIONARY_DEFAULT}

# -- ------------------------------------
# -- Private
# -- ------------------------------------

# Emulate 'local' if needed

if [ "${KSH_VERSION:-}" ]; then
    if ! command -v local > /dev/null 2>&1; then
        if command -v typeset > /dev/null 2>&1; then
            # Use eval to hide from shell parsers
            eval 'local () { typeset "$@" ; }'
        fi
    fi
fi

AtExitDefault ()
{
    if [ "${TMPBASE:-}" ]; then
        $RM --force "$TMPBASE"*
    fi
}

SetupTrapAtExit ()
{
    if ! IsCommandExist AtExit; then
        # Define default AtExit

        # ignore never invoked
        # shellcheck disable=SC2329
        AtExit ()
        {
            AtExitDefault
        }
    fi

    trap AtExit EXIT HUP INT QUIT TERM
}

TrapReset ()
{
    # Clear our traps
    trap - EXIT HUP INT QUIT TERM
}

IsCommandExist ()
{
    [ "${1:-}" ] || return 1

    command -v "$1" > /dev/null 2>&1
}

IsMatchGlob () # args: GLOB STR
{
    # No args, return error condition

    [ "${1:-}" ] || return 1
    [ "${2:-}" ] || return 1

    # ignore quotes
    # shellcheck disable=SC2254

    case $2 in
        $1)
            return 0
            ;;
        *)  return 1
            ;;
    esac
}

IsUnameMatch ()
{
    IsMatchGlob "${1:-}" "$(uname -a)"
}

Warn ()
{
    echo "$*" >&2
}

Die ()
{
    Warn "$*"
    exit 1
}

DieEmpty ()
{
    [ "${1:-}" ] && return 0

    shift
    Die "$*"
}

DieOptionNotNumber ()
{
    case ${2:-} in
        [0-9]*)
            ;;
        *)
            Die "$PROGRAM: ERROR: option ${1:-} requires a number, got: ${1:-}"
            ;;
    esac
}

DieOptionMinus ()
{
    case ${2:-} in
        -*)
            Die "$PROGRAM: ERROR: option ${1:-} requires ARG, got $2"
            ;;
    esac
}

DieOptionEmpty ()
{
    if [ ! "${2:-}" ]; then
        Die "$PROGRAM: ERROR: option ${1:-} requires ARG, got empty"
    fi
}

DieOption ()
{
    DieOptionMinus "$@"
    DieOptionEmpty "$@"
}

DieNoFile ()
{
    if [ ! -e "${1:-}" ]; then
        Die "$PROGRAM: ERROR: no such file: ${1:-}"
    fi
}

DieEmptyFile ()
{
    if [ ! -s "${1:-}" ]; then
        Die "$PROGRAM: ERROR: empty file: ${1:-}"
    fi
}

DieNoDir ()
{
    if [ ! -d "${1:-}" ]; then
        Die "$PROGRAM: ERROR: no such dir: ${1:-}"
    fi
}

IsVerbose ()
{
    [ "${VERBOSE:-}" ]
}

Verbose ()
{
    IsVerbose || return 0
    "$@"
}

IsOsWinCygwin ()
{
    # Also set under MobaXterm

    [ "${OSTYPE:-}" = "cygwin" ] ||
    [ -d /cygdrive/c ]
}

IsOsWinMobaxterm ()
{
    [ -d /home/mobaxterm ]
}

IsOswinMsystem ()
{
    # uname --all # contains "Msys"

    [ "${MSYSTEM:-}" ] ||
    [ "${MSYSTEM_PREFIX:-}" ] ||
    [ "${OSTYPE:-}" = "msys" ] ||
    [ -d /c ]
}

IsOsLinux ()
{
    [ "${OSTYPE:-}" = "linux-gnu" ] ||
    [ "$(uname)" = "Linux" ]
}

IsOsLinuxLike ()
{
    IsOsLinux ||
    IsOsWinCygwin ||
    IsOswinMsystem
}

IsOsDebian ()
{
    # http://linuxmafia.com/faq/Admin/release-files.html

    [ -f /etc/debian_version ] ||
    IsUnameMatch "*Debian*"
}

IsOsUbuntu ()
{
    IsUnameMatch "*Ubuntu*"
}

IsOsDebianLike ()
{
    IsOsDebian || IsOsUbuntu
}

IsOsWinWsl ()
{
    [ "${WSL_DISTRO_NAME:-}" ] && return 0
    [ "${WSLENV:-}"          ] && return 0
    [ "${WSL_INTEROP:-}"     ] && return 0
    [ -e /usr/bin/wslinfo    ] && return 0

    IsUnameMatch "*microsoft*"
}

# TODO: IsShellAsh
# TODO: IsShellDash
# TODO: IsShellBusybox

IsShellPosh ()
{
    # pdksh derivate shell
    [ "${POSH_VERSION:-}" ]
}

IsShellBash ()
{
    [ "${BASH_VERSION:-}" ]
}

IsShellBashFeatureCompat ()
{
    # https://www.gnu.org/software/bash/manual/bash.html#Shell-Compatibility-Mode
    # Bash-4.3 introduced a new shell
    # variable: BASH_COMPAT

    case ${BASH_VERSION:-} in
        4.[4-9]* | [5-9]*)
            return 0
            ;;
        *)  return 1
            ;;
    esac
}

IsShellKsh93 ()
{
    IsMatchGlob "*93*" "${KSH_VERSION:-}"
}

IsShellMksh ()
{
    IsMatchGlob "*MIRBSD*" "${KSH_VERSION:-}"
}

IsShellKsh ()
{
    [ "${KSH_VERSION:-}" ]
}

IsShellZsh ()
{
    [ "${ZSH_VERSION:-}" ]
}

IsShellModern ()
{
    IsShellBash  ||
    IsShellKsh93 ||
    IsShellZsh
}

IsFeatureConditionalExpression ()
{
    # Shells that support:
    # [[ ... ]]

    IsShellModern ||
    IsShellMksh
}

IsFeatureMatchPattern ()
{
    # Shells that support:
    # [[ abc == *b* ]]

    IsFeatureConditionalExpression
}

IsFeatureMatchRegexp ()
{
    # Shells that support:
    # [[ string =~ $RE ]]

    IsShellModern
}

IsFeatureDictionary ()
{
    [ -e "$DICTIONARY_FILE" ]
}

IsFeatureArrays ()
{
    IsShellModern ||
    IsShellMksh
}

IsFeatureProcessSubstitution ()
{
    IsShellModern
}

IsFeatureReadOptionN ()
{
    # read -N<size>
    IsShellModern
}

IsFeatureCommandSubstitutionReadFile ()
{
    # Shells that support:
    # $(< file)
    # https://www.gnu.org/software/bash/manual/bash.html#Command-Substitution

    IsShellModern
}

IsFeatureMatchGlob ()
{
    # Shells that support:
    # [[ string = *str* ]]

    IsShellModern ||
    IsShellMksh
}

IsFeatureHereString ()
{
    # Shells that support HERE STRING
    # cmd <<< "str"
    #
    # https://mywiki.wooledge.org/BashFAQ/061

    IsShellModern ||
    IsShellMksh
}

IsFeatureArray ()
{
    IsShellModern
}

IsFeatureArraysHereString ()
{
    IsFeatureArrays &&
    IsFeatureHereString
}

IsCommandParallel ()
{
    IsCommandExist "${PARALLEL:-}"
}

IsCommandStat ()
{
    IsCommandExist "${STAT:-}"
}

IsCommandPushd ()
{
    IsCommandExist pushd
}

IsCacheGnu ()
{
    [ "${1:-}" ] || return 1

    : "debug: case"    # no-op but seen under 'set -x'

    case ${T_LIB_CACHE_GNU:-} in
        *" $1 "*)
            return 0
            ;;
        *)
            return 1
    esac
}

CacheGnuSave ()
{
    local cmd
    cmd=${1:?ERROR: missing arg: cmd}

    if ! IsCacheGnu "$cmd"; then
        T_LIB_CACHE_GNU="$T_LIB_CACHE_GNU $cmd "
    fi

    unset cmd
    return 0
}

IsCommandGnuVersion ()
{
    [ "${1:-}" ] || return 1

    IsCacheGnu "$1" && return 0

    case $("$1" --version 2> /dev/null) in
        *GNU*)
            CacheGnuSave "$1"
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

IsCommandGnuStat ()
{
    IsCommandGnuVersion stat
}

IsCommandGnuAwk ()
{
    IsCommandGnuVersion awk
}

IsCommandGnuGrep ()
{
    IsCommandGnuVersion grep
}

IsCommandGnuFind ()
{
    IsCommandGnuVersion find
}

RequireParallel ()
{
    IsCommandParallel && return 0
    Die "${1:-}: ERROR: no GNU parallel(1) in PATH. Set envvar \$PARALLEL"
}

RequireDictionary ()
{
    IsFeatureDictionary && return 0
    Die "${1:-}: ERROR: missing requirement: $DICTIONARY_DEFAULT. Set envvar \$DICTIONARY_FILE"
}

RequireBash ()
{
    IsShellBash && return 0
    Die "${1:-}: ERROR: no GNU bash(1) in PATH"
}

RequireGnuStat ()
{
    IsCommandGnuStat && return 0
    Die "${1:-}: ERROR: no GNU stat(1) in PATH. Set envvar STAT"
}

RequireGnuAwk ()
{
    IsCommandGnuAwk && return 0
    Die "${1:-}: ERROR: no GNU awk(1) in PATH. Set envvar AWK"
}

RandomWordsGibberish ()
{
    # - Create file with SIZE containing random words.
    # - Limit output to column 80.
    # - Separate words by spaces.

    local dev
    dev=/dev/urandom

    if [ -e "$dev" ]; then
        : # ok
    elif [ -e /dev/random ]; then
        dev=/dev/random
    else
        Die "ERROR: no /dev/urandom"
    fi

    IsCommandExist "$BASE64" || Die "ERROR: not in PATH: $BASE64"

    $BASE64 --decode "$dev" |
        $TR --complement --delete 'a-zA-Z0-9 ' |
        $FOLD --width=80 |
        $HEAD --bytes="${1:-100k}"

    unset dev
}

RandomWordsDictionary ()
{
    local size
    size=${1:-1M}

    RequireDictionary "t-lib.sh"

    # Ksh93 bug (workaround)
    #
    # For unknown reasing the large output
    # of 'shuf' cannot be piped to
    # awk without getting an error
    # 'shuf: write error: Connection reset by peer'
    #
    # Use temporary file to work around the bug

    local _tmp
    _tmp=$(mktemp -t "$TMPBASE.random.dictionary.$size.XXX.tmp")

    ${SHUF:-shuf} --head-count=200000 "$DICTIONARY_FILE" > "$_tmp"

    # ignore AWK single quote
    # shellcheck disable=SC2016

    ${AWK:-awk} '
        BEGIN {
            total_size = 0;
        }

        {
            if (length(line) + length($0) + 1 <= 80)
            {
                if (length(line) > 0)
                    line = line " " $0;
                else
                    line = $0;
            }
            else
            {
                print line;
                total_size += length(line) + 1;
                line = $0;
            }
        }

        END {
            if (length(line) > 0)
            {
                print line;
                total_size += length(line) + 1;
            }
        }' "$_tmp" |
    ${HEAD:-head} --bytes="${1:-100k}"

    ${RM:-rm} --force "$_tmp"
    unset _tmp
}

RandomNumbersAwk ()
{
    [ "${1:-}" ] || return 1

    RequireGnuAwk "t-lib.sh"

    ${AWK:-awk} \
    '
    BEGIN {
        srand();

        for (i = 1; i <= n; i++)
            print int(rand() * (2**14 - 1))
    }' n="$1" < /dev/null # ' fix. Ksh parser bug: "quote may be missing"
}

RandomNumbersPerl ()
{
    [ "${1:-}" ] || return 1

    ${PERL:-perl} -e "print int(rand(2**14-1)) . qq(\n) for 1..$1"
}

RandomNumbersPython ()
{
    [ "${1:-}" ] || return 1

    $PYTHON -c "import random; print('\n'.join(str(random.randint(0, 2**14-1)) for _ in range($1)))"
}

RunMaybe ()
{
    [ "${1:-}" ] || return 0

    if IsCommandExist "${1:-}" ; then
        ${1:-}
    fi
}

RunTestCase ()
{
    [ "${1:-}" ] || return 1

    local format hasformat timecmd

    # We're supposing recent Bash 5.x or Ksh
    # which defines TIMEFORMAT

    format="real %3R  user %3U  sys %3S" # precision 3: N.NNN

    if [ "$ZSH_VERSION" ]; then
        # https://zsh.sourceforge.io/Doc/Release/Parameters.html
        #
        # hasformat="TIMEFMT"
        # format="real %*E  user %*U  sys %*S"

        # ... maybe later release can
        Die "ERROR: t(): Abort, zsh cannot time(1) functions"

    elif [ "$BASH_VERSION" ]; then
        # https://www.gnu.org/software/bash/manual/bash.html#Bash-Variables
        hasformat="TIMEFORMAT"

    elif [ "$KSH_VERSION" ]; then
        case ${KSH_VERSION:-} in
            *MIRBSD*)
                # No format choice
                # in mksh(1)
                ;;
            *)  hasformat="TIMEFORMAT"
                ;;
        esac

    else
        case ${0:-} in
            ksh | */ksh | */ksh93*)
                hasformat="TIMEFORMAT"
                ;;
        esac
    fi

    # -------------------------------------------------------
    # Run
    # -------------------------------------------------------

    timecmd=""

    case $(command -v time 2>&1) in
        /*) # /usr/bin/time - cannot be used to run functions
            ;;
        time)
            timecmd="time"
            ;;
    esac

    if [ "$hasformat" ]; then
        local timeformat
        timeformat=""

        eval "timeformat=\$$hasformat" # save
        printf "# %-24s" "$1"

        eval "$hasformat='$format'"    # set

        time "$@"

        eval "$hasformat='$timeformat'" # restore
        unset timeformat

    elif [ "$timecmd" ]; then
        # Format the output using other means.

        # Wed Feb 12 15:16:15 EET 2025 0m00.00s real 0m00.00s user 0m00.00s system
        # =============================
        # |
        # sed:
        # - delete up till 'real'
        # - convert multiple spaces to 2
        # - convert tabs to 2 spaces
        #
        # mksh:
        # 0m00.08s real  0m00.05s user  0m00.03s system
        #
        # - convert "0m00" => "0"
        # - change order of fields:
        #   0m00.08s real ... => real 0m00.08s ...

        # ignore AWK single quote
        # shellcheck disable=SC2016

        { time "$@" ; } 2>&1 |
            paste --serial --delimiters=" " |
            ${SED:-sed} \
                --regexp-extended \
                --expression 's,^.*[[:space:]]+([0-9]+m[0-9.]+s[[:space:]]+real),\1, ' \
                --expression 's,   +,  ,g' \
                --expression 's,\t,  ,g' |
            $TR --delete '\n' |
            $AWK '
            {
                gsub(/0m00/, "0")
                sub(/system/, "sys")

                if (match($2, "real"))
                {
                    # 0.08s real  ... => real 0.08s
                    $0 = $2 " " $1 "  " $4 " " $3 "  " $6 " " $5
                }

                printf "# %-24s%s\n", test, $0
            }' test="$1"  # ' comment fix. Ksh bug: does not see closing quote

    else
        Die "ERROR: t(): Abort, no suitable built-in time command in Shell"
    fi

    unset hasformat format timecmd
}

TestData ()
{
    [ "${1:-}" ] || return 1

    # Create test data to use with all test cases.
    #
    # AWK is the fastest
    #
    # 0m0.008s  awk
    # 0m0.011s  perl
    # 0m0.043s  python
    #
    # time RandomNumbersAwk "$1" > /dev/null
    # time RandomNumbersPerl "$1" > /dev/null
    # time RandomNumbersPython "$1" > /dev/null

    if [ ! -s "$random_file" ]; then
        RandomNumbersAwk "${1:-}" > "$random_file"
    fi
}

t ()
{
    local dummy test
    dummy="t()"
    test=${1:-}

    if [ ! "$test" ]; then
        Warn "WARN: t() called without a test case"
        unset dummy test
        return 1
    fi

    shift

    # Can be called in following Ways
    #
    #   t <test case>
    #   t <test case> <arg> <rgs> ...
    #
    # for <args>, run those as "$@" to determine
    # if <test case> should be being run.

    if [ "${1:-}" ]; then
        if "$@"; then
            RunTestCase "$test"
        else
            printf "# %-24s<skip>\n" "$test $*"
        fi
    else
        RunTestCase "$test"
    fi

    unset dummy test
}

RunTestSet ()
{
    local dummy test testset saved
    dummy="RunTestSet()"

    testset=${1:-}
    shift

    saved=$IFS
    IFS=":
"

    for test in $testset
    do
        test="$test"   # For debug
        eval "$test"
    done

    IFS=$saved

    unset dummy test testset saved test
}

RunTests ()
{
    local dummy
    dummy="RunTests()"

    # ARG 1 is list of tests to run in
    # format "[:]<test case>:<test case>..."
    #
    # Any newline is ignored.
    # The <test cases> are separated by colon":"
    # Leading and trailing colon is ignored.
    #
    # if ARG 2 is present, the ARG 1 is ignored
    # and all argumens from ARG 2 are
    # considered set of test cases to run, like
    # "t1" "t2" ...

    local tests

    tests=${1:-}
    tests=${tests#:}  # Delete leading ":"
    tests=${tests%:}  # Delete trailing ":"
    shift

    RunMaybe Info

    local arg

    if [ "${1:-}" ]; then
        arg=$1
        shift

        dummy="check:condition"

        if [ "${1:-}" ]; then # Pre-condition
            printf "%-28s " "$arg $*"

            if "$@" ; then
                "$arg"
            else
                printf "<skip> "
            fi
        else
            # Unused, but useful during debug
            # shellcheck disable=SC2034
            dummy="run:doit"

            printf "%-28s " "$arg"
            "$arg"
        fi
    else
        RunTestSet "$tests"
    fi

    unset dummy arg tests
}

# By default; create test file

[ "${source:-}" ] || TestData "$random_file_count"

# End of file
