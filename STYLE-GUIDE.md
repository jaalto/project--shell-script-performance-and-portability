<!--

Link: https://is.gd/bGeOoE

https://github.com/jaalto/project--shell-script-performance-and-portability/blob/master/SHELL-SCRIPT-CODING-STYLE.md

INFORMATION FOR EDITING

- Github Markdown Guide:
  https://is.gd/nqSonp

- View markdown in VSCode:
  Command Palette (C-S-p)
  Markdown: Open Preview C-S-v
  Markdown: Open Preview to the side C-k v
  [upper right:eye-icon button] Open Preview to the Side

- URL text fragments: #:~:text=
  https://developer.mozilla.org/en-US/docs/Web/URI/Reference/Fragment/Text_fragments

- About accessibility

  To support viewing and editing GitHub
  pages on phone displays, the maximum
  column widths are described below.
  Exception: The GNU License at the end
  of file is included verbatim.

  The maximum column limits are:

  col type
  --- -------------------------
  31  Code: bullet: ``` ... ``´)
  41  Regular text and paragraphs.
      Github line limit to support
      editing.
  --- ------------------------------

  Emacs editor settings:

  ;; eval code with C-x C-e
  (progn
    (setq fill-column 41)
    (display-fill-column-indicator-mode 1))

MISCELLANEOUS

- To search POSIX.1-2024 in Google
  site:pubs.opengroup.org inurl:9799919799 <search>

-->


# SHELL SCRIPT STYLE GUIDE

## 1. Core Principles

### 1.1 General

- Use [POSIX] conventions where possible
  to improve portability.

- Use conventions that maximize
  simplicity and clarity. Embrace
  minimalism in the spirit of the
  [Less Is More] philosophy (LIM),
  similar to KISS
  [Keep It Short and Simple].

- Utilize [ShellCheck] or other [linting]
  tools to improve code quality.

- Prioritize minimum effort over rigorous
  standards for small controlled scripts.

- When sharing code intended for a wider
  audience, or for deployment in a
  production or operational environment,
  strictly adhere to best pactises, like
  variable quoting, to prevent unexpected
  behavior.

### 1.2 Code Organization and Modularity

For best practises, divide shell script
into sections. They are:

- The shebang
- The comment block
- Constants
- Functions
- Program body in Main()

In order to easily find the start of the
program, put the entry point in a
function called `Main` as the bottom-most
function. This provides consistency with
the existing programming languages and
allows readers to find the start of the
program immediately. Using a function
also enables the use of local variables
for the main logic.

A template for entry point:
```shell
Main ()
{
    local arg
    arg=${1:-}

    echo "command line: $arg"
}

Main "$@"
```

### 1.3 Consistent Conventions

Shell scripts can be written in a variety
of styles. To make scripts easier to read
and understand, use consistent naming
conventions and style.

Commonly used conventions include
[Snake case] (e.g., my_variable) or
[Camel case] (e.g., myVariable). Follow a
consistent code style, such as indenting
with spaces or tabs, using spaces around
operators, and placing blocks and braces
on the same line or a new line.

This guide adopts the following conventions:

- Functions use [CamelCase]: Start with
  an uppercase letter. **Rationale:**
  Uppercase function names minimize
  conflicts with existing lowercase shell
  commands.
- Variables start with a lowercase
  letter. **Rationale:** Underscore
  characters increase visual noise.
  Compare `thisVar="$hasVal $likeThis"` vs
  `this_var="$has_val $like_this"`.
- Indentation: Spaces are used over TAB
  characters. **Rationale:** The layout
  remains uniform across editors,
  terminals, and tools like diff(1),
  where TAB widths vary. Additionally,
  copy-pasting code preserves the exact
  formatting.
- Blocks use primarily [Allman] style
  over [K&R]. **Rationale:** To maximize
  clarity; placing braces on their own
  lines reduces "noise" in the logical
  lines of code.

### 1.4 Script Preamble and Dependencies

- Prefer `/bin/sh`. This ensures maximum
  portability and execution speed.
  Improve readability by adding a space
  after the interpreter path in [shebang]
  line:

``` bash
  #! /bin/sh
```

- Assume [GNU coreutils] and require
  their installation in the README. GNU
  utilities are more capable and
  generally optimized for speed. They
  also provide standardized behavior
  regardless of the OS, ensuring
  improved interoperability.

- **Utilities trade-off to the POSIX
  portability focus**: In calling
  utilities (e.g. `grep`), use readable
  GNU `--long` options where possible.
  **Rationale:** `--long` options make
  scripts easier to read and maintain in
  the long term.

- **Standard options in scripts:** A
  standard set of options should be
  utilized by every script to ensure a
  uniform user interface. At a minimum,
  `-h` (help) must be implemented.
  **Rationale:** User expectations are
  best met by providing standardized
  interface.

Option| Long Option |Description
---   | ---         | ---
-h    | --help      |Display usage instructions and exit
-v    | --verbose   |Increase output detail for monitoring.
-V    | --version   |Print version information and exit.
-D    | --debug     |(Optional) Enable tracing output.

``` shell
   # Code for option handling
   #
   # NOTE: POSIX `getopts`
   # utility does not support
   # long options. The
   # Limitation of the code
   # is that it does not
   # provide stacked short
   # options in form of "-l
   # -x" => "-lx"

   while :
   do
        local opt
        opt="${1:-none}"

        case $opt in
            -v | --verbose)
                shift
                VERBOSE="verbose"
                ;;
            -V | --version)
                shift
                # Calls exit 0
                Version
                ;;
            -D | --debug)
                shift
                DEBUG="debug"
                ;;
            -h | --help)
                shift
                # Calls exit 0
                Help
                ;;
            --) # End of options
                shift
                break
                ;;
            -*)
                shift
                echo "$0: WARN Unknown option: $opt" >&2
                ;;
            *)
                break
                ;;
        esac
    done
```

- Documentation. Add a top-level
  comment block including:
  **License:** Consult
  [SPDX License List]. Prefer known
  licences like GPL, MIT etc.
  **Description:** What the script
  does. **Usage:** Example of how
  to call it. The easiest is to
  provide `Help` near the top of
  the script.

``` shell
    #! /bin/sh
    #
    #   <file> -- <description>
    #
    #   Copyright
    #
    #       Copyright (C) YYYY Firstname Lastname <email>
    #
    #   License
    #
    #       This program is free software; you can redistribute it and/or
    #       modify it under the terms of the GNU General Public License as
    #       published by the Free Software Foundation; either version 2 of the
    #       License, or (at your option) any later version
    #
    #       This program is distributed in the hope that it will be useful, but
    #       WITHOUT ANY WARRANTY; without even the implied warranty of
    #       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
    #       General Public License for more details.
    #
    #       You should have received a copy of the GNU General Public License
    #       along with program; see the file COPYING. If not, write to the
    #       Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    #       Boston, MA 02110-1301, USA.
    #
    #       Visit <http://www.gnu.org/copyleft/gpl.html>
    #
    #   Usage
    #
    #       See the --help option.
    #
    #   Dependecies
    #
    #       GNU utilities: grep, gawk etc.

    Help ()
    {
        # See sections and
        # formatting ideas in
        # the manual pages.

        echo "\
    SYNOPSIS
        $0 [options]

    OPTIONS
        -f, --file FILE
            Use FILE.

        -t, --test
            Run in test mode.

        -D, --debug
            Turn on debug.

        -v, --version
            Display version and exit.

        -v, --verbose
            Display verbose message.

        -h, --help
            Display help and exit.

    DESCRIPTION
        <...>

    FILES
        <...>

    ENVIRONMENT
        <...>
    "
        exit 0
    }
```

## 2. Rules

### 2.1 Error Handling

- At the beginning of file, explicitly
  set shell options for early exit and
  error checking. Use variations of the
  [unofficial bash strict mode]. For
  robustness, include at least the first
  two options. **Rationale:** These
  settings (*errexit, nounset*) treat
  errors and unset variables as fatal,
  preventing unexpected behavior. Be sure
  to also Learn their caveats from
  [Bash FAQ/105] and [Bash Pitfalls/60].

``` shell
    #! /bin/sh

    # Use readable long options
    # instead of 'set -eu'

    # Recommended
    # - Exit on error
    # - unused vars
    set -o errexit
    set -o nounset

    # Optional
	# - fail on $()
	# - fail cmd on pipe
    set -o errtrace
    set -o pipefail
```

- Set a exit status: Scripts should exit
  with 0 for success and a non-zero
  value to indicate a failure or
  specific error condition.

- Check status of commands and
  exit early.

``` shell
    # in case you do not use
    # set -o errexit

    cd "$dir" || exit $?
```

- Use safe temporary files and
  directories with `mktemp`.
  **Rationale:** Prevent symlink attacks
  and race conditions in multi-user
  environments. See [Bash FAQ/062].

``` shell
    tmpfile=$(mktemp -t tmp.file.XXX)
    tmpdir=$(mktemp --directory -t tmp.dir.XXX)
```

- Use a [trap] to ensure proper cleanup
  of temporary files on script exit.
  See [Bash Guide/SignalTrap].

``` shell

  AtExit ()
  {
     # rm temporary files
  }

  trap 'AtExit' EXIT HUP INT QUIT TERM
```

### 2.2 Variables and Quoting

- Global Variables: Use `ALL_CAPS` for
  global, environmental, or read-only
  constants.

- Use `"$quoted"` variables.

- Use `"$@"`, that is, quote the "all
  arguments" [special parameters]
  variable. This is mandatory to keep
  each argument distinct and uncorrupted.

- Prefer simple `$var` by default. Use the
  braces only when necessary for boundary
  conditions (e.g., `${var}suffix`) or
  when utilizing shell
  [parameter expansion] (e.g.,
  `${var:-default}`). **Rationale:**
  minimalism in the spirit of
  [Less Is More].

``` shell
    path="$dir/$to/$file"

    # Not like this
    path="${dir}/${to}/${file}"
```

- Rule: Use simple truth tests for
  boolean checks. Omit explicit `-n`
  (non-zero length) or `-z` (zero length)
  options. Always wrap the variable in
  double quotes. **Rationale:**
  [Less is More]. For programmers coming
  from Python, Ruby, or Perl, simple
  truth tests are intuitive and familiar.
  Explicit flags don't add functional
  value when values are in double-quotes.
  Minimizing these options reduces
  cognitive load to promote to use more
  universal programming logic.

``` bash
    [ "$var" ]    # Has value
    [ ! "$var" ]  # No value

    # Not preferrered
    [ -n "$var" ]
    [ -z "$var" ]
```

### 2.3 Formatting and Syntax

- The Maximum line length is 80
  characters. **Rationale:** this limit
  is a deliberate constraint based on
  human physiology and complexity
  management. Human eyes scan vertical
  text much faster than horizontal text
  (C.f. newspaper columns and
  speed-reading). With limited space,
  complex logic must be broken out, or
  refactored into more manageable parts
  Less code per line is better than more.

- Use 4 spaces for indentation.

- Use blank lines between blocks to
  improve readability.

- Use the [Allman] "line up" style in
  `do..done`

``` shell
    for item in 1 2 3
    do
        ...
    done

    while :
    do
        ...
    done
```

- Place pattern case terminators `;;` in
  their own lines. **Rationale:**
  Improves the visual flow and make the
  action blocks stand out.

``` shell
    # Note: POSIX case require
    # no quotes for $var
    # because it does not
    # undergo word splitting or
    # globbing.

    case $var in
        pattern1)
            ...
            ;;
        pattern2)
            ...
            ;;
    esac
```

- Use [K&R] style for placing `then`
  keyword provided that `<statement>` is
  short and simple enough.

``` shell
    if <statement>; then
        ...
    fi

    # In longer statements,
    # switch to Allman style
    # for more clarity. Command
    # is more visually
    # prominent (it stands out
    # better).

    if <this is an example of a very long statement>
    then
        ...
    fi
```

### 2.4 Input/Output and File Handling

- Send error messages to stderr.

``` bash
    echo "ERROR: message" >&2

    # Not like this
    echo >&2 "ERROR: message"
```

- Display help to stdout. Displaying
  help, program version etc. are not
  error conditions.

``` bash
    arg=${1:-}

    if [ "$arg" = "-h" ]; then
        echo "Synopsis: ...."
        exit 0
    fi
```

- Use `read -r`. **Rationale:** When
  reading input with read, always use the
  `-r` option to prevent backslash
  interpretation, which can lead to
  unexpected behavior. See
  [Bash FAQ/001].

``` bash
    while read -r item
    do
        ...
    done < file
```

- [Command Substitution]: Use POSIX
  `$(command)` instead of archaic
  backticks \`command\` for command
  substitution. **Rationale:** it allows
  for cleaner nesting and is generally
  easier to read. Both are POSIX, but
  the dollar-parentheses form is
  preferred. See [Bash FAQ/082].

``` bash
    # Use
    dirname="$(basename "$(pwd)")"

    # Instead of ...
    dirname=`basename \`pwd\``
```

### 2.5 Functions and Scope

- Use the standard POSIX parentheses
  syntax to define functions; avoid the
  non-standard [function keyword].

``` shell
   Example ()
   {
      # POSIX
   }

   function Example ()
   {
      # Bash, Zsh only
   }
```

- Prefer including a space before the
  function parentheses `()` to match the
  output style of the [Bash type]
  command. **Rationale:** Shell functions
  are treated as internal commands rather
  than traditional programming functions.
  Because `()` is not used for argument
  passing in shell functions, a new
  command—behaving similarly to `ls`-—is
  emphasized by the `Name ()` notation,
  rather than a subroutine with a fixed
  signature.

``` shell
    Example ()
    {
        # arguments in $1, $2,
        # etc., not the parens
    }

    # Behaves like a system
    # command
    Example "arg"
```

- **Function Argument Handling:** in
  longer functions prefer assigning
  positional arguments (`$1`, `$2` etc.)
  immediately to meaningful, local
  variables to improve readability within
  the function.

``` shell
    Example ()
    {

        # Use 'local' though
        # not strictly POSIX.
        # It's widely supported
        # in modern /bin/sh
        # implementations.

        local file
        file="${1:-}"
    }
```

### 2.6 Notes on local keyword

- **Note: Dynamic scope:** The shell uses
  dynamic scoping to control a variable’s
  visibility within functions. See
  [functions] in Bash manual. This means
  that a function can see variables
  defined not just inside itself, but
  also variables defined by any other
  function that called it.

``` shell
    Two ()
    {
        echo "$var" # "hello"
    }

    One ()
    {
        local var
        var="hello"

        Two
    }

    One
```

- **About [Korn Shell]
  compatibility**. If supporting BSD or
  UNIX systems that may use `ksh` as
  `/bin/sh` is required, include the
  necessary code at the script's start to
  emulate the `local` keyword.

``` shell
    IsCommand ()
    {
        [ "${1:-}" ] || return 1
        command -v "${1:-}" > /dev/null 2>&1
    }

    if ! IsCommand local; then
        if IsCommand typeset; then
            # Use 'eval' to
            # hide statement.
            # Would otherwise
            # cause program
            # to exit due to
            # parse error at
            # 'local' keyword.

            eval 'local () { typeset "$@"; }'
        fi
    fi

    PortableLocal ()
    {
        # Portable use of local.
        # On its own lines:
        # - Declaration
        # - Assignment

        local var
        var="value"
    }
```

### 2.7 Other notes

**echo vs printf**

POSIX [echo] does not have any options.
Use it for static strings. Use
[printf] when you require options.
Arbitrary rules like 'use printf for
everyting' is not sound advice as it
would lead to less readable code.

``` shell
    # Simple

    echo "display this"
    echo "and more of that"

    # vs
    #
    # Tthe proper safe way to
    # use printf is to *always*
    # include "%s"

    printf "%s\n" "display this"
    printf "%s\n" "and more of that"
```

**$PWD vs $(pwd)**

POSIX defines the variable [PWD]. You
can use it in place of the command
[pwd]. For shells where `pwd` is not a
built-in, it is slightly more efficient
to use the variable, as it avoids a
subshell fork.

``` shell
    curdir=$PWD    # PREFERRED
    curdir=$(pwd)
```

**Long commands**

To improve readability, split commands
and options in their own lines according
to clean code priciple: one line does
one thing.

``` shell
    sed -e 's/^ +//'   \
        -e 's/ +$//'   \
        -e 's/  +/ /g' \
        file
```

**Pipes and long commands**

In the [Google Bash Style Guide] section
on "pipelines," there is an example of
how to split a long pipe chain across
separate lines.

While aligning the pipe (|) at the start
of lines is visually pleasing, it
requires redundant backslashes (\) at
the end of each preceding line. In the
spirit of [Less is More] (LIM), a
trailing pipe naturally indicates that
the command continues on the next line,
making the backslash redundant. This
reduces visual noise and eliminates the
risk of "trailing space" syntax errors,
as indentation alone is sufficient to
express the separation of commands.

``` shell
    # LIM, lean, simpler
    command1   |
      command2 |
      command3

    # Google
    command1 \
      | command2 \
      | command4
```

The same LIM priciple applies (no
backslash needed) to also other
operators:

``` shell
    command1     &&
        command2 &&
        command3 &&

    command1     ||
        command2 ||
        command3 ||
```

**Keep It Simple**

Use standard `if..fi`. Avoid clever
logical `&&` or `||`. Complex blocks
sacrifice clarity for readers unfamiliar
with shell shorthands.

``` shell
    if <statement>; then
        # Preferred.
        # Clear to all readers
    fi

    <statement> && {
        # Not like this
    }
```

**Mathematical Calculations**

Less is more: omit the `$` in POSIX
arithmetic expansions. The shell
automatically treats names as variables
and evaluates their values and using the
`$` inside the parenthese is redundant.

``` shell
    result=$((n + m))   # preferred
    result=$(($n + $m))
```

The POSIX `$((...))` only handles
integers. For decimals, use `bc` or
`awk`.

``` shell
    i=0.5
    j=0.1

    # No leading zero: .6
    k=$(echo "$i + $j" | bc)

    # With leading zero: 0.6
    k=$(printf "%g" "$(echo "$i + $j" | bc)")

    # POSIX awk
    k=$(i="$i" j="$j" awk 'BEGIN {print ENVIRON["i"] + ENVIRON["j"] }')
```

**Suggested global variables**

Here is list of suggested global
variables at the top of for distributed
shell scripts.

``` shell
    PROGRAM=${0##*/}
    AUTHOR="John doe <jdoe@example.com>"
    URL="http://example.com/project/homepage"

    # See
    # https://spdx.org/licenses
    # for correct short names
    LICENSE="GPL-3-or-later"

    # Use machine
    # readable format N.N[.N]
    #
    # For proction code,
    # use standard X.Y.Z
    #
    # Date based version may
    # be useful for small
    # projects or infrequent
    # releases.
    VERSION="YYYY.MMDD.HHMM"
```

## 3. Bash Notes

### 3.1 Bash shebang

Use the portable `env` [shebang] line.
  Improve readability by adding a space
  after the interpreter path.

``` shell
  #! /usr/bin/env bash
```

### 3.2 Limit Bashism

Even in Bash, default to POSIX syntax
unless Bash-specific features are
explicitly required.

Consult https://mywiki.wooledge.org/Bashism
for more ideas how to reduce Bash specific
features.

**Rationale:** This ensures broader
system portability and later
compatibility with `/bin/sh`, allowing
scripts to benefit from faster startup
and fewer forks.


## 3.3 STATEMENT TO BE AVOIDED

Avoid `$[...]` syntax and the the `let` built-in.
They have no uses.

## 3.4 VARIABLES

Favor `local` for variable scoping within
functions. Avoid the Bash-specific
[declare] built-in. **Rationale:** Less
is more.

## 3.5 ARITHMETIC

Avoid Bash-specific constructs like the
arithmetic expression `((...))`

Examples:

``` shell
    # Instead of ...
    for ((i=1; i <= 10; i++))
    do
        ...
    done

    # Use portable POSIX. No
    # real performance
    # difference
    for i in $(seq 10)
    do
        ...
    done
```

## 3.6 TEST CONDITIONS

For simple tests, avoid
[double bracket] conditional `[[...]]`.
Instead, use the portable POSIX [test]
command `[...]` and always quote
variable expansions. Develop a
consistent quoting habit
ensures safety, correctness, and
portability.

``` shell
    # Instead of ...
    if [[ $a = $b ]]; then
        ...
    fi

    # Use portable POSIX-style
    # with quoting
    if [ "$a" = "$b" ]; then
        ...
    fi
```

## 4. REFERENCES

- Allman style (aka BSD style)
  https://en.wikipedia.org/wiki/Indentation_style#Allman_style
- K&R style
  https://en.wikipedia.org/wiki/Indentation_style#K&R
- Linting - static code analysis
  https://en.wikipedia.org/wiki/Lint_(software)
- Shellcheck - static shell script code
  analysis
  https://www.shellcheck.net
- The "Unofficial Bash strict mode" blog
  post by Aaron Maxwell introduced on a
  concept similar to 'use strict'
  (warning: the blog contains few serious
  errors, like not quoting `"$@"`). This
  concept was first introduced in 1990s
  in the [Perl] programming language and
  later adopted by others, like
  [Javascript strict mode],
  [[C# struct mode],
  [Haskell -Xstrict extension], Nodejs
  library [react strict mode],
  [Powershell scrict mode], etc.

<!-- links -->

<!-- ------- REF:LANG -------- -->

[Korn Shell]: https://en.wikipedia.org/wiki/KornShell
[ksh]: https://en.wikipedia.org/wiki/KornShell

<!-- ------- REF:BASH -------
Google search help:
  site:www.gnu.org inurl:bash <search words>
-->

[arithmetic expression]: https://www.gnu.org/software/bash/manual/html_node/Shell-Arithmetic.html
[double bracket]: https://www.gnu.org/software/bash/manual/bash.html#ndex-_005b_005b
[functions]: https://www.gnu.org/software/bash/manual/html_node/Shell-Functions.html
[function keyword]: https://www.gnu.org/software/bash/manual/html_node/Shell-Functions.html
[bash type]: https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html#index-type
[declare]: https://www.gnu.org/software/bash/manual/bash.html#index-declare

[Bash FAQ/001]: https://mywiki.wooledge.org/BashFAQ/001
[Bash FAQ/082]: https://mywiki.wooledge.org/BashFAQ/082
[Bash FAQ/062]: https://mywiki.wooledge.org/BashFAQ/062
[Bash FAQ/105]: https://mywiki.wooledge.org/BashFAQ/105
[Bash Pitfalls/60]: https://mywiki.wooledge.org/BashPitfalls#set_-euo_pipefail
[Bash Guide/SignalTrap]: https://mywiki.wooledge.org/SignalTrap


<!-- ------- REF:POSIX ------- -->

[POSIX]: https://pubs.opengroup.org/onlinepubs/9799919799/
[special parameters]: https://www.gnu.org/software/bash/manual/html_node/Special-Parameters.html
[command substitution]: https://www.gnu.org/software/bash/manual/html_node/Command-Substitution.html
[parameter expansion]: https://pubs.opengroup.org/onlinepubs/009604499/utilities/xcu_chap02.html#tag_02_06_02
[PWD]: https://pubs.opengroup.org/onlinepubs/9799919799/utilities/V3_chap02.html#:~:text=PWD
[echo]: https://pubs.opengroup.org/onlinepubs/9799919799/utilities/echo.html
[let]: https://www.gnu.org/software/bash/manual/bash.html#index-let
[printf]: https://pubs.opengroup.org/onlinepubs/9799919799/utilities/printf.html
[pwd]: https://pubs.opengroup.org/onlinepubs/9799919799/utilities/pwd.html
[sed]: https://pubs.opengroup.org/onlinepubs/9799919799/utilities/sed.html
[test]: https://pubs.opengroup.org/onlinepubs/9799919799/utilities/test.html
[trap]: https://www.gnu.org/software/bash/manual/bash.html#index-trap
[type]: https://pubs.opengroup.org/onlinepubs/9799919799/utilities/type.html

<!-- ------- REF:GNU --------- -->

[GNU coreutils]: https://www.gnu.org/software/coreutils/

<!-- ------- REF:MISC ------- -->

[shebang]: https://en.wikipedia.org/wiki/Shebang_(Unix)
[shellcheck]: https://www.shellcheck.net
[CamelCase]: https://en.wikipedia.org/wiki/Camel_case
[Camel case]: https://en.wikipedia.org/wiki/Camel_case
[Snake case]: https://en.wikipedia.org/wiki/Snake_case
[Allman]: https://en.wikipedia.org/wiki/Indentation_style#Allman_style
[K&R]: https://en.wikipedia.org/wiki/Indentation_style#K&R
[test]: https://pubs.opengroup.org/onlinepubs/9799919799/utilities/test.html
[linting]: https://en.wikipedia.org/wiki/Lint_(software)

[unofficial bash strict mode]: http://redsymbol.net/articles/unofficial-bash-strict-mode/
[Javascript strict mode]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Strict_mode
[Haskell -Xstrict extension]: https://gitlab.haskell.org/ghc/ghc/-/wikis/strict-pragma
[react strict mode]: https://react.dev/reference/react/StrictMode
[C# struct mode]: https://www.meziantou.net/csharp-compiler-strict-mode.htm
[Powershell scrict mode]: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/set-strictmode?view=powershell-7.5

[SPDX License List]: https://spdx.org/licenses/
[Keep It Short and Simple]: https://en.wikipedia.org/wiki/KISS_principle
[Less Is More]: https://en.wikipedia.org/wiki/Less_is_more

[Google Bash Style Guide]: https://google.github.io/styleguide/shellguide.html

<!-- ------- REF:LANG -------- -->

[Perl]: //www.perl.org
[Python]: https://www.python.org
[Ruby]: https://www.ruby-lang.org

<!-- END OF FILE -->
