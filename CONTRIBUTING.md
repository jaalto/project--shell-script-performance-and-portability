# CONTRIBUTING

Information for contributing test cases.

About writing test cases: Write as simple and clean as
possible. Do not treat as a production code, which means:

- Leave out quotes from variables. Write: `$var` and not
  `"$var"`.
- No need to use `local` command. Each test case is a
  independent unit whose variables do not affect others.
- No need for [shellcheck] linting.

# TEST CASE FILE LAYOUT

Write documentation comments at the
beginning of the `<test case>.sh` files
in markdown format. The comments "# "
will be stripped during documentation
conversion. See
[txt2markdown.sh](./bin/txt2markdown.sh).

The commentary format:

```text
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

```text
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


```text
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

```text
    Short: <In less than 40 chars, summary>
    Desc: <In one sentence, description>
```

  An example:

```text
    #! /bin/bash
    # Short: arrays
    # Desc: Test array support

    array=(1 2 3)
    : "${array[1]}"
```

- Name performance `<test case>` files as
  `xp-performance-*.sh`. Each file contains a
  simple feature test. The program can use
  command line arguments. A single integer
  return value indicates the result.

```
    Short: <In less than 40 chars, summary>
    Desc: <In one sentence, description>
```

  An example:

```shell
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

- The `<test case>` file must return to the same
  directory on exit (if it uses `cd`).

- Variables. Use short variable names. From
  [t-lib.sh](./bin/t-lib.sh) use global `TMPBASE` to
  create temporary files.

```
    f="$TMPBASE.this-test-file-name.tmp"
```

- To clean  `TMPBASE` derived temporary
  files using
  Special Built-In Utility [trap]
  see examples below: For custom cleanup,
  define function `AtExit` and call `AtExitDefault`to manually
  clean `TMPBASE` files.

```shell
    # Use default
    # defines AtExit to clean TMPBASE* files
    SetupTrapAtExit
```

Or use custom clean up:

```shell
    AtExit ()
    {
        # Clean all $TMPBASE* files first
        AtExitDefault

        # ... the rest
        rm --recursive --force $tmpdir
    }

    SetupTrapAtExit AtExit    # Use your custom AtExit
```

- Name the test case functions using `t<number>[something]()`, like
  `t1`, `t2` or `t3a`, `t3b`. Order the test cases by fastest
  solution first and slowest last. Every test case must be
  independent.

```shell
    t1 ()
    {
        # test case
    }
```

- If needed, you can define function `Info` to display
  information before test cases are being run.

```shell
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

```shell
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

End of file

<!-- links -->

<!-- ------- REF:POSIX ------- -->

[trap]: https://www.gnu.org/software/bash/manual/bash.html#index-trap
[shellcheck]: https://www.shellcheck.net

<!-- END OF FILE -->
