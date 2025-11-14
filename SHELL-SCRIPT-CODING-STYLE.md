# SHELL SCRIPT CODING STYLE

Use conventions that maximize clarity and
simplicity.

[Linting] is good practice. Utilize [shellcheck].

It is acceptable to prioritize minimum effort
over rigorous standards for small scripts.

**Example**: The intentional omission of double
quotes around variables (e.g., `$var` instead
of `"$var"`) is contextual and not always a
sign of unprofessionalism; it depends heavily
on the use case and expected input.

On the other hand, when sharing code intended
for a wider audience, or for deployment in a
production or operational environment,
strictly adhere to shell scripting best
practices, including robust variable quoting,
to prevent unexpected behavior and guarantee
cross-platform reliability.

- Prefer `/bin/sh`. This ensures
  maximum portability and execution speed.

- For Bash scripts, use the portable `env`
  shebang. Improve readability by adding a
  space after the interpreter path.

```
  #! /usr/bin/env bash
```

- Even in Bash scripts, minimize the use of
  Bashisms. Rationale: Simplifies possible
  conversion to more portable `/bin/sh`
  scripts. For example, instead of using
  double brackets ´[[...]]`, make it a habit
  to use more "safe" quoting.

```
  [[ $var = $value ]]   # Bash
  [ "$var" = "$value" ] # POSIX, portable
```


- Use 4 spaces for indentation.

- Assume GNU utilities. Use readable GNU
  `--long` options where possible.
  Note: The GNU utilies are
  optimized for speed.

- Prefer `"$quoted"` variables.

- Prefer `$var` by default. Avoid `${var}`.
  Use the braces only when necessary for
  boundary conditions (e.g., `${var}suffix`) as
  the extra sigils compromise line
  readability. Compare:

```
  path="$dir/$to/$MY_FILE_NAME"

  path="${dir}/${to}/${MY_FILE_NAME}"
```

- In variable tests, use practical
  and simple notations. Avoid `-z`
  or `-n` [test] options.

```
    [ "$var" ]    # Has value
    [ ! "$var" ]  # Empty, does not have a value
```


- In functions, prefer names using
  [CamelCase]. Start identifier with an
  uppercase letter to minimize conflict to
  existing commands. Avoid the Bash-only
  `function` keyword; use the standard POSIX
  parentheses syntax Avoid the use of
  Bash-only `function` keyword. Prefer
  including a space before the function
  parentheses `()` matching Bash `type`
  command output.

```
    # Non-POSIX: "function Example () ..."
    Example ()
    {
        local var="value"
    }
```

- In functions, use `local` for variables. While
  not POSIX-compliant, it is supported by
  virtually all modern Linux `/bin/sh`
  implementations. **Exception**: For
  compatibility with certain BSD or UNIX
  systems using ksh as `/bin/sh`, use the
  following code at the script's start to
  emulate the `local` keyword:

``` bash
    IsCommand ()
    {
        command -v "${1:-}" > /dev/null 2>&1
    }

    # Check if 'local' is supported
    if ! IsCommand local; then
        # Check if we are in ksh
        if IsCommand typeset; then
            # Use 'eval' to hide from
            # other shells so that
            # defining function with
            # name 'local' does not
            # generate an error.
            eval 'local () { typeset "$@"; }'
        fi
    fi
```

- Use the [Allman] "line up" style in
  `do..done`

```
    for item in $list
    do
        ...
    done

    while read -r item
    do
        ...
    done < file
```

- Place pattern case terminators `;;' in
  their own lines to improves the visual flow
  and make the action blocks stand out.

```
    case $var in
        pattern1)
            ...
            ;;
        pattern2)
            ...
            ;;
    esac
```

- Use [K&R] style for placing `then` keyword
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

- Keep it simple; avoid cleverness. Always
  favor the standard `if...fi` structure.
  Logical `&&` or `||` blocks sacrifice
  clarity for readers unfamiliar with shell
  shorthands.

```
    <statement> && {
        ....
    }
```

# REFERENCES

- Allman style (aka BSD style)
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
[test]: https://pubs.opengroup.org/onlinepubs/9799919799/utilities/test.html
[linting]: https://en.wikipedia.org/wiki/Lint_(software)
