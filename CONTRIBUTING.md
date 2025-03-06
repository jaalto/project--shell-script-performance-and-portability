# CONTRIBUTING

information for contributing more test cases.

# TEST CASE FILE LAYOUT

```
    Q: <In one sentence, test case description>
    A: <In one sentence, major results>
    priority: 0-10

    <The time(1) performance results>

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

# GENERAL TEST CASE FILE CONVENTIONS

- Name test files as "t-<category>-*.sh",
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

- Name the test case functions using `t<number>[something]()`, like
  t1, t2 or t3a, t3b. Order the test cases (if posisble) by fastest
  solution first and slowest last.

# GENERAL CODING STYLE CONSIDERATIONS

Use relaxed conventions for maximum clarity
and simplicity. The <test case> files are
intended to be as clear and straightforward
as possible and not Production Code.

No need to lint using shellcheck(1) etc.
Ref: <https://www.shellcheck.net>.

- For readability, use space in shebang line:

```
  #! /bin/bash
  ... code
```

- Use 4 spaces for indentation.

- Use readable `--long` options for commands
  that support them.

- Do not `"$quote"` variables unless needed.

- No `local` variables unless needed.

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
