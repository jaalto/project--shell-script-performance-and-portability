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
#       Requires GNU utilities first in PATH. Those
#       of sed, awk, cut, head, tr etc. Used GNU --long
#       options for calling commands (code maintenance).
#
# Description
#
#       This is a library. Common
#       utilities. When sourced, it will
#       create the following test file to
#       be used by <test cases>:
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
#           $STAT
#           $TR
#
#           $loop_max
#           $random_file
#           $random_file_count

# -- ------------------------------------

# -- ------------------------------------
# -- Exported variables
# -- ------------------------------------

PROGRAM=$0
TMPBASE=${LOGNAME:-$USER}.$$.test

VERBOSE=""
T_LIB_CACHE_GNU=""

# -- ------------------------------------
# -- User settable env variables
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
SED=${SED:-"sed"}
STAT=${STAT:-"stat"} # Must be GNU version
TR=${TR:-"tr"}

DICTIONARY_DEFAULT="/usr/share/dict/words"
DICTIONARY_FILE=${DICTIONARY_FILE:-$DICTIONARY_DEFAULT}

# -- ------------------------------------
# -- Private variables
# -- ------------------------------------

RUNNER=t.run

[ "${KSH_VERSION:-}" ] && alias local=typeset

AtExitDefault ()
{
    rm --force "$TMPBASE"*
}

SetupTrapAtExit ()
{
    if ! IsCommandExist AtExit; then
        # Define default AtExit
        AtExit ()
        {
            AtExitDefault
        }
    fi

    trap AtExit EXIT HUP INT QUIT TERM
    unset trap
}

TrapReset ()
{
    trap - EXIT HUP INT QUIT TERM
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

IsVerbose ()
{
    [ "$VERBOSE" ]
}

Verbose ()
{
    IsVerbose || return 0
    "$@"
}

IsCommandExist ()
{
    command -v "${1:?ERROR: missing ARG}" > /dev/null
}

IsOsCygwin ()
{
    [ -d /cygdrive/c ]
}

IsOsLinux ()
{
    [ "$(uname)" = "Linux" ]
}

IsUnameMatch ()
{
    case $(uname -a) in
        ${1:-})
            return 0
            ;;
        *)  return 1
            ;;
    esac
}

IsOsDebian ()
{
    # http://linuxmafia.com/faq/Admin/release-files.html
    [ -f /etc/debian_version ] || IsUnameMatch "*Debian*"
}

IsOsUbuntu ()
{
    IsUnameMatch "*Ubuntu*"
}

IsOsDebianLike ()
{
    IsOsDebian || IsOsUbuntu
}

# TODO: IsShellAsh
# TODO: IsShellDash

IsShellPosh ()
{
    [ "${POSH_VERSION:-}" ]   # Pdkd derivate
}

IsShellBash ()
{
    [ "${BASH_VERSION:-}" ]
}

IsShellBashFeatureCompat ()
{
    # https://www.gnu.org/software/bash/manual/bash.html#Shell-Compatibility-Mode
    # Bash-4.3 introduced a new shell variable: BASH_COMPAT

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
    case ${KSH_VERSION:-} in
        *93*)
            return 0
            ;;
    esac

    return 1
}

IsShellMksh ()
{
    case ${KSH_VERSION:-} in
        *MIRBSD*)
            return 0
            ;;
    esac

    return 1
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
    IsShellBash || IsShellKsh93 || IsShellZsh
}

IsFeatureDictionary ()
{
    [ -e "$DICTIONARY_FILE" ]
}

IsFeatureArrays ()
{
    IsShellModern || IsShellMksh
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
    # $(< file)
    # https://www.gnu.org/software/bash/manual/bash.html#Command-Substitution
    IsShellModern
}

IsFeatureMatchRegexp ()
{
    # [[ string =~ ^abc ]]
    IsShellModern
}

IsFeatureMatchGlob ()
{
    # [[ string = *str* ]]
    IsShellModern || IsShellMksh
}

IsFeatureHereString ()
{
    # Check HERE STRING support like this:
    # cmd <<< "str"
    # Ref: https://mywiki.wooledge.org/BashFAQ/061

    IsShellModern || IsShellMksh
}

IsFeatureArray ()
{
    IsShellModern
}

IsCommandParallel ()
{
    IsCommandExist "$PARALLEL"
}

IsCommandStat ()
{
    IsCommandExist "$STAT"
}

IsCommandPushd ()
{
    IsCommandExist pushd
}

IsCacheGnu ()
{
    local cmd
    cmd==${1:?ERROR: missing arg: cmd}

    case ${T_LIB_CACHE_GNU:-} in
        *$cmd*)
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
        T_LIB_CACHE_GNU="$T_LIB_CACHE_GNU $cmd"
    fi

    return 0
}

IsCommandGnuVersion ()
{
    local cmd
    cmd=${1:-}

    [ "$cmd" ] || return 1

    IsCacheGnu "$cmd" && return 0

    case $("$cmd" --version 2> /dev/null) in
        *GNU*)
            CacheGnuSave "$cmd"
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

    local dev=/dev/urandom

    if [ -e "$dev" ]; then
        : # ok
    if [ -e /dev/random ]; then
        dev=/dev/random
    else
        Die "ERROR: no /dev/urandom"
    fi

    IsCommandExist "$BASE64" || Die "ERROR: not in PATH: $BASE64"

    base64 --decode "$dev" |
        $TR --complement --delete 'a-zA-Z0-9 ' |
        $FOLD --width=80 |
        $HEAD --bytes="${1:-100k}"
}

RandomWordsDictionary ()
{
    RequireDictionary "t-lib.sh"

    shuf --head-count=200000 "$DICTIONARY_FILE" |
    $AWK '
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
        }' |
    head --bytes=${1:-100k}
}

RandomNumbersAwk ()
{
    [ "${1:-}" ] || return 1

    RequireGnuAwk "t-lib.sh"

    $AWK \
    '
    BEGIN {
        srand();

        for (i = 1; i <= n; i++)
            print int(rand() * (2**14 - 1))
    }' \
    n="$1" \
    < /dev/null
}

RandomNumbersPerl ()
{
    [ "${1:-}" ] || return 1

    $PERL -e "print int(rand(2**14-1)) . qq(\n) for 1..$1"
}

RandomNumbersPython ()
{
    [ "${1:-}" ] || return 1

    $PYTHON -c "import random; print('\n'.join(str(random.randint(0, 2**14-1)) for _ in range($1)))"
}

RunMaybe ()
{
    local cmd
    cmd=${1:-}

    [ "$cmd" ] || return 0

    if IsCommandExist "$cmd" ; then
        $cmd
    fi
}

RunTestCase ()
{
    [ "${1:-}" ] || return 1

    # We're supposing recent Bash 5.x or Ksh
    # which defines TIMEFORMAT

    local format hasformat
    format="real %3R  user %3U  sys %3S" # precision 3: N.NNN

    if [ "$ZSH_VERSION" ]; then
        # https://zsh.sourceforge.io/Doc/Release/Parameters.html
        # hasformat="TIMEFMT"
        # format="real %*E  user %*U  sys %*S"

        # ... maybe later release can
        Die "ERROR: t(): Abort, zsh cannot time(1) functions"
    elif [ "$BASH_VERSION" ]; then
        # https://www.gnu.org/software/bash/manual/bash.html#Bash-Variables
        hasformat="TIMEFORMAT"
    elif [ "$KSH_VERSION" ]; then
        case ${KSH_VERSION:-} in
            *MIRBSD*) # No format choice in mksh(1)
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

    local timecmd
    timecmd=""

    case $(command -v time 2>&1) in
        /*) # /usr/bin/time - cannot be used to run functions
            ;;
        time)
            timecmd="time"
            ;;
    esac

    if [ "$hasformat" ]; then
        eval "timeformat=\$$hasformat" # save
        printf "# %-24s" "$1"

        eval "$hasformat='$format'"    # set

        time "$@"

        eval "$hasformat='$timeformat'" # restore
        unset timeformat

    elif [ "$timecmd" ]; then

        # Format the output using other means.

        printf "# $1  "

        # Wed Feb 12 15:16:15 EET 2025 0m00.00s real 0m00.00s user 0m00.00s system
        # =============================
        # |
        # sed: delete this part and limit output to 2 spaces.

        { time "$@" ; } 2>&1 |
            paste --serial --delimiters=" " |
            ${SED:-sed} \
                --regexp-extended \
                --expression 's,^.* +([0-9]+m[0-9.]+s +real),\1, ' \
                --expression 's,   +,  ,g' \
                --expression 's,\t,  ,g' |
            tr -d '\n'
        echo  # Add newline
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
        RandomNumbersAwk "$1" > "$random_file"
    fi
}

t ()
{
    local dummy
    dummy="t()"

    local test
    test=${1:-}

    if [ ! "$test" ]; then
        Warn "WARN: t() called without a test case"
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
            RunTestCase $test
        else
            printf "# %-24s<skip>\n" "$test $*"
        fi
    else
        RunTestCase $test
    fi

    unset dummy test
}

RunTestSet ()
{
    local dummy
    dummy="RunTestSet()"

    local testset
    testset=${1:-}
    shift

    local saved
    saved=$IFS
    IFS=":
"

    local test

    for test in $testset
    do
        eval $test
    done

    IFS=$saved

    unset dummy testset saved test
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
    # considered <test cases> to run,

    local tests
    tests=${1:-}
    tests=${tests#:}  # Delete leading ":"
    tests=${tests%:}  # Delete trailing ":"
    shift

    RunMaybe Info

    if [ "${1:-}" ]; then
        local arg
        arg=$1
        shift

        dummy="check:condition"

        if [ "${1:-}" ]; then # Condition
            printf "%-28s " "$arg $*"
            if "$@" ; then
                "$arg"
            else
                printf "<skip> "
            fi
        else
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
