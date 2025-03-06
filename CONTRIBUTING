# CONRIBUTING

information for contributing more test cases.

# TEST CASE FILE LAYOUT

```
    Q: <In one sentence, test case description>
    A: <In one sentence, major results>
    priority: 0-10

    <The time(1) performance results>

    Code:

    <Optinal explanatory code for the reader>

    Notes:

    <About the test cases, analysis
    of the results, commentary, notes>
```

Based on the results, select <priority> as
follows regarding impact on performance:

```
    9-10 critical – High impact
    7-8  high – Significant impact
    5-6  medium – Some, but not critical
    3-4  low – Minimal, but still measurable
    0-2  negligible – Consider unimportant
```

# GENERAL TEST CASE FILE CONVENTIONS

- Start with readable shebang with
  space "#! /bin/bash"

- Name test files "t-<category>-*.sh", where
  category is one of:

```
    command      - extermal commands
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

# GENERAL CODING STYLE CONSIDERATIONS

Use relaxed conventions for maximum clarity
and simplicity. The <test case> files are
intended to be as straightforward as possible
and not Production Code.

No need to lint using shellcheck(1) etc.
Ref: <https://www.shellcheck.net>.

- Use readable --long options everywhere.

- Do not "$quote" unless needed.

- No 'local' variables unless needed.

- Allman style for these:

```
    fn()
    {
        ...
    }

    for <test>
    do
        ...
    done

    case "$var" in
        glob) ...
              ;;
        glob) ...
              ;;
    fi
```

- K&R style for placing 'then'
  provided that <cmd> is short and simple
  enough.

```
    if <cmd>; then
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
