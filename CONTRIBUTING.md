# CONTRIBUTING

information for contributing more test cases.

# TEST CASE FILE LAYOUT

Write documentation comments in the <text case>.sh files as
they would appear in markdown. The comments
"# " will be stripped during documentation conversion.
See [txt2markdown.sh](./bin/Makefile::d).

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

Based on the results, select <priority> as
follows regarding the impact on performance:

```
    9-10 critical – High impact
    7-8  high – Significant
    5-6  medium – Some
    3-4  low – Minimal, but still measurable
    0-2  negligible – Consider unimportant
```

# GENERAL TEST CASE FILE NAMING

- Name <test case> files
  as `t-<category>-*.sh`,
  where category is one of:


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

- Name portability <test case> files as
  `x-portability-*.sh`. If testing utilities
  (cut, read, etc.) defined in POSIX, name the
  file `x-portability-posix-*.sh`. Each file
  contains a simple shell feature test. The
  return code indicates whether the feature is
  supported.


```
   # FILE: x-portability-array.sh
   # Q: Test array support
   a=(1 2 3)

   # To test feature from command line
   bash x-portability-array.sh ; echo $?
   dash x-portability-array.sh ; echo $?
   ...

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

# GENERAL CODING STYLE CONSIDERATIONS

Use relaxed conventions for maximum clarity
and simplicity. The <test case> files are
intended to be as clear and straightforward
as possible and not Production Code.

No need to lint using `shellcheck` etc.
Ref: <https://www.shellcheck.net>.

- Write for target shell Bash. For macOS portability
  use `/usr/bin/env'. Use space in shebang line
  to help readability.

```
  #! /usr/bin/env bash
```

- Use 4 spaces for indentation.

- Use readable `--long` options for commands
  that support them.

- Do not `"$quote"` variables unless needed.

- No `local` variables unless needed.

- Define function names in
  [camelCase[(https://en.wikipedia.org/wiki/Camel_case)
  style.

- Use Allman style for these:

```
    fn()
    {
        ...
    }

    <loop statement>
    do
        ...
    done

    case <string> in
        pattern)
			...
			;;
        pattern)
			...
			;;
    fi
```

- K&R style for placing `then` keyword
  provided that `<statement>` is short and
  simple enough.

```
    if <statement>; then
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

End of file
