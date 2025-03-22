#  -*- mode: sh; -*-
#
#   t-lib.sh - Liibrary of common shell functions for testing.
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
#       . <file>
#
# Description
#
#       This is a library. Common utilities. When sourced, it will
#       create the following test files to be used by <test cases>:
#
#           t.random.numbers.tmp
#
#       Global variables used:
#
#           $verbose         in Verbose()
#
#       Exported variables:
#
#           $random_file
#           $loop_max

# Exported variables
PROGRAM=$0

TMPBASE=${TMPDIR:-/tmp}/${LOGNAME:-$USER}.$$.test

# create random number test file
random_file=${random_file:-t.random.numbers.tmp}
loop_max=${loop_max:-100}

STAT=${STAT:-"stat"} # must be GNU version
AWK=${AWK:-"AWK"}    # preferrably GNU version

DICTIONARY_DEFAULT="/usr/share/dict/words"
DICTIONARY=${DICTIONARY:-$DICTIONARY_DEFAULT}

# Private variables. Will be unset after end of the file.
random_file_count=${random_file_count:-10000}
RUNNER=t.run

[ "${KSH_VERSION:-}" ] && alias local=typeset

AtExit ()
{
    rm --force "$TMPBASE"*
}

EnableDefaultTrap ()
{
    trap AtExit EXIT HUP INT QUIT TERM
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

Verbose ()
{
    [ "$verbose" ] || return 0
    echo "$*"
}

IsOsCygwin ()
{
    [ -d /cygdrive/c ]
}

IsOsLinux ()
{
    [ "$(uname)" = "Linux" ]
}

IsOsDebian ()
{
    command -v apt-get > /dev/null
}

# TODO: IsShellAsh
# TODO: IsShellDash

IsShellPosh ()
{
    [ "${POSH_VERSINFO:-}" ]   # Pdkd derivate
}

IsShellBash ()
{
    [ "${BASH_VERSINFO:-}" ]
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
    IsShellBash || IsShellKsh || IsShellZsh
}

IsFeatureDictionary ()
{
    [ -e "$DICTIONARY" ]
}

IsFeatureArrays ()
{
    IsShellModern
}

IsFeatureReadOptionN ()
{
    # read -N<size>
    IsShellModern
}

IsFeatureMatchRegexp ()
{
    # [[ $string =~ $re ]]
    IsShellModern
}

IsFeatureHereString ()
{
    # Check HERE STRING support like this:
    # cmd <<< "str"
    # Ref: https://mywiki.wooledge.org/BashFAQ/061

    IsShellModern
}

IsFeatureArray ()
{
    IsShellBash || IsShellZsh || IsShellKsh
}

IsCommandTest ()
{
    command -v "${1:?ERROR: missing ARG}" > /dev/null
}

IsCommandParallel ()
{
    IsCommandTest parallel
}

IsCommandStat ()
{
    IsCommandTest stat
}

IsCommandPushd ()
{
    IsCommandTest pushd
}

IsCommandGnuVersion ()
{
    [ "${1:-}" ] || return 1

    case "$("$1" --version 2> /dev/null)" in
        *GNU*)
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

IsCommandParallel ()
{
    command -v parallel
}

RequireParallel ()
{
    IsCommandParallel && return 0
    Die "${1:-}: ERROR: no requirement: parallel(1) not in PATH"
}

RequireDictionary ()
{
    IsFeatureDictionary && return 0
    Die "${1:-}: ERROR: no requirement: $DICTIONARY_DEFAULT or set envvar \$DICTIONARY"
}

RequireBash ()
{
    IsShellBash && return 0
    Die "${1:-}: ERROR: no requirement: Bash"
}

RequireGnuStat ()
{
    IsCommandGnuStat && return 0
    Die "${1:-}: ERROR: no requirement: GNU stat(1), or set envvar STAT"
}

RequireGnuAwk ()
{
    IsCommandGnuAwk && return 0
    Die "${1:-}: ERROR: no requirement: GNU awk(1), or set envvar AWK"
}

Runner ()
{
    runit="$RUNNER.$$"

    echo "$*" > "$runit"

    sh ./"$runit"

    rm --force "$runit"
    unset runit
}

RandomWordsGibberish ()
{
    # - Create file with SIZE containing random words.
    # - Limit output to column 80.
    # - Separate words by spaces.

    base64 --decode /dev/urandom |
        tr --complement --delete 'a-zA-Z0-9 ' |
        fold --width=80 |
        head --bytes="${1:-100k}"
}

RandomWordsDictionary ()
{
    RequireDictionary "t-lib.sh"

    shuf --head-count=200000 "$DICTIONARY" |
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

    $AWK -v n="$1" \
    '
    BEGIN {
        srand();

        for (i = 1; i <= n; i++)
            print int(rand() * (2**14 - 1))
    }'
}

RandomNumbersPerl ()
{
    [ "${1:-}" ] || return 1

    perl -e "print int(rand(2**14-1)) . qq(\n) for 1..$1"
}

RandomNumbersPython ()
{
    [ "${1:-}" ] || return 1

    python3 -c "import random; print('\n'.join(str(random.randint(0, 2**14-1)) for _ in range($1)))"
}

RunTestCase () # Run a test case
{
    [ "${1:-}" ] || return 1

    # We're supposing recent Bash 5.x or Ksh
    # which defines TIMEFORMAT

    format hasformat 2> /dev/null
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
        case "$KSH_VERSION" in
            *MIRBSD*) # No format choice in mksh(1)
                ;;
            *)  hasformat="TIMEFORMAT"
                ;;
        esac
    else
        case "$0" in
            ksh | */ksh | */ksh93*)
                hasformat="TIMEFORMAT"
                ;;
        esac
    fi

    # -------------------------------------------------------
    # Run
    # -------------------------------------------------------

    timecmd=""

    case "$(command -v time 2>&1)" in
        /*) # /usr/bin/time - cannot be used to run functions
            ;;
        time)
            timecmd="time"
            ;;
    esac

    if [ "$hasformat" ]; then
        eval "timeformat=\$$hasformat" # save
        printf "# %-15s" "$1"

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
            sed --regexp-extended \
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
    dummy="t()"

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
            printf "# %s ... skip, no pre-condition: %s\n" $test "$*" >&2
        fi
    else
        RunTestCase $test
    fi

    unset dummy test
}

RunTestSet ()
{
    dummy="RunTestSet()"
    testset=${1:-}
    shift

    saved=$IFS
    IFS=":
"

    for test in $testset
    do
        eval $test
    done

    IFS=$saved

    unset dummy test testset saved
}

RunTests ()
{
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

    tests=${1:-}
    tests=${tests#:}  # Delete leading ":"
    tests=${tests%:}  # Delete trailing ":"
    shift

    if [ "${1:-}" ]; then
        arg=$1
        shift

        dummy="check:condition"

        if [ "${1:-}" ]; then # Condition
            printf "%-28s " "$arg $*"
            if "$@" ; then
                $arg
            else
                printf "<skip> "
            fi
        else
            printf "%-28s " "$arg"
            $arg
        fi
    else
        RunTestSet "$tests"
    fi

    unset dummy arg tests
}

# Create file

TestData $random_file_count
unset random_file_count

# End of file
