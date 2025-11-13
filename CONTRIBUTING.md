# CONTRIBUTING

information for contributing test cases.

# TEST CASE FILE LAYOUT

Write documentation comments in the `<test
case>.sh` files as they would appear in
markdown. The comments "# " will be stripped
during documentation conversion. See
[txt2markdown.sh](./bin/Makefile::d).

```
    Q: <In one sentence, test case description>
    A: <In one sentence, major results>
    priority: 0-10

    <The time performance results>

    Code:

    <Optional explanatory code for the reader>

    Notes:

    <About the test cases, analysis
    of the results, commentary, notes>
```

Based on the results, select \<priority\> as
follows regarding the impact on performance:

```
    9-10 critical – High impact
    7-8  high – Significant
    5-6  medium – Some
    3-4  low – Minimal, but still measurable
    0-2  negligible – Consider unimportant
```

# GENERAL TEST CASE FILE NAMING

- Name <test case> files as
  `t-<category>-*.sh`, where category
  is one of:


```
    command     - external commands
    dir         - directory related
    file        - file manipulation
    function    - function usage
    statement   - language structures
    string      - string manipulation
    variable    - Anything about variables.
                  Use subtype prefix:
                  variable-var-*
                  variable-array-*
                  variable-hash-*
```

- Name portability \<test case\> files as extra
  `x-portability-*.sh`. If testing utilities
  which are defined in POSIX (`cut`, `read`,
  etc.), name the file
  `x-portability-posix-*.sh`. Each file
  contains a simple shell feature test. The
  return code indicates whether the feature
  is supported. Add two comment lines at
  the top of the file:

```
    Short: <In less than 40 chars, summary>
    Desc: <In one sentence, description>
```

  An example:

```
    #! /bin/bash
    # Short: arrays
    # Desc: Test array support

    array=(1 2 3)
    : "${array[1]}"
```

- Name performance <test case> files as extra
  `xp-performance-*.sh`. Each file contains a
  simple feature test. The program can use
  command line arguments. A single integer
  return value indicates the result.

```
    Short: <In less than 40 chars, summary>
    Desc: <In one sentence, description>
```

  An example:

```
#! /bin/sh
# Short: while loop
# Desc: Measure while loop and external awk call count
#
# Notes:
#
# Useful to test overall disk speed and system latency.
# E.g in one system and then in another.

timeout 1 ${1:-bash} <<'EOF' 2> /dev/null

trap 'echo "$n"; trap - EXIT TERM INT; exit' EXIT TERM INT

n=0

while :
do
    awk 1 < /dev/null
    n=$((n + 1))
done
EOF

# End of file
```

# TEST CASE FILE FORMAT

- The <test case> file must return to the same
   directory on exit (if it uses `cd`).

- Variables. Use short variable names. From
  [t-lib.sh](./bin/t-lib.sh) use global `TMPBASE` to
  create temporary files.

```
    f="$TMPBASE.this-test-file-name.tmp"
```

- To clean  `TMPBASE` derived temporary
  files using
  Special Built-In Utility
  [`trap`](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_28),
  see examples below: For custom cleanup,
  define function `AtExit` and call `AtExitDefault`to manually
  clean `TMPBASE` files.

```
    SetupTrapAtExit # defines AtExit to clean TMPBASE* files

    AtExit ()
    {
        AtExitDefault # Clean TMPBASE* files
        rm --recursive --force $tmpdir  # my custom cleanup
    }

    SetupTrapAtExit AtExit    # Use your custom AtExit
```
z
- Name the test case functions using `t<number>[something]()`, like
  t1, t2 or t3a, t3b. Order the test cases by fastest
  solution first and slowest last. Every test case must be
  independent.

```
    t1 ()
    {
        # test case
    }
```

- Define function `Info` to display information once
  before test cases are being run.

```
    Info ()
    {
        ls -l $f  # Test file information
    }
```

- Define test cases to be run in a string, where test cases
  are separated by colons. If test case requires
  pre-condition, for example shell or feature,
  use `Is<test>` function from
  [t-lib.sh](./bin/t-lib.sh)
```
    # Define lists of test cases,
    # leading colon(:) at
    # the beginning of string
    # is ignored.
    #
    # Test cases t1 and t2 can be run
    # only under shells that meet the
    # criteria.
    #
    # Test case t3 can be run under any
    # POSIX shell.

    t="\
    :t1 IsFeatureArrays
    :t2 IsShellBash
    :t3
    "

    # Run test cases. The "source" variable
    # use defined when called using
    #
    #   run.sh --shell dash <test case>.sh

    [ "$source" ] || RunTests "$t" "$@"

```

# PROJECT CODING STYLE

Use conventions to maximize clarity
and simplicity. The \<test case\> files are
intended to be as clear and straightforward
as possible and not Production Code.

No mandatory lint needed using [shellcheck]
etc.

- Write in POSIX `sh` if possible.

- For Bash scripts, use the portable `env`
  shebang. Improve readability by adding a
  space after the interpreter path.

```
  #! /usr/bin/env bash
```

- Use 4 spaces for indentation.

- Assume GNU utilities. Use readable GNU
  `--long` options for all supporting
  commands. Adherence to POSIX short options
  is not required.

- No need to `"$quote"` variables unless
  needed.

- Use `local` keyword in functions to define
  variables. Although not in POSIX, it is
  99% supported in all modern shells.

- In variable tests, use practical
  and simple notations. Do not use `-z`
  or `-n` tests.

```
	[ "$var" ]    # Has value
	[ ! "$var" ]  # Empty, does not have a value
```

- Define function names using [CamelCase].
  Start identifier with an uppercase letter
  to minimize conflict to existing
  commands. Always include a space before the
  function parentheses '()' matching Bash
  `type` command output, and do not use the
  non-POSIX `function` keyword.

- Use [Allman] style for these:

```
    ThisFunctionName ()
    {
        ...
    }

	for item in $list
    do
        ...
    done

	while read -r item
    do
        ...
    done < file

    case $var in
        pattern1)
            ...
            ;;
        pattern2)
            ...
            ;;
    fi
```

- Use K&R style for placing `then` keyword
  provided that `<statement>` is short and
  simple enough.

```
    if <statement>; then
        ...
    fi

    # In longer statements, switch to [Allman]
	# for more clarity

    if <this is an example of a very long statement>
    then
        ...
    fi
```


# REFERENCES

- Allman aka BSD style
  https://en.wikipedia.org/wiki/Indentation_style#Allman_style
- K&R style
  https://en.wikipedia.org/wiki/Indentation_style#K&R
- Linting - static code analysis
  https://en.wikipedia.org/wiki/Lint_(software)
- Shellcheck - static shell script code analysis
  https://www.shellcheck.net

<!-- links -->

[shellcheck]: https://www.shellcheck.net
[CamelCase]: https://en.wikipedia.org/wiki/Camel_case
[Allman]: https://en.wikipedia.org/wiki/Indentation_style#Allman_style
[K&R]: https://en.wikipedia.org/wiki/Indentation_style#K&R

End of file
