<!--

Link: https://is.gd/bGeOoE

https://github.com/jaalto/project--shell-script-performance-and-portability/blob/master/SHELL-SCRIPT-CODING-STYLE.md

-->

# SHELL SCRIPT CODING STYLE

## Principles

Use conventions that maximize clarity and
simplicity.

Utilize [ShellCheck] or other [linting] tools
to improve code quality.

Prioritize minimum effort over rigorous
standards for small controlled scripts.

when sharing code intended
for a wider audience, or for deployment in a
production or operational environment,
strictly adhere to best pactises, like
variable quoting, to prevent unexpected
behavior.

## General rules

- Prefer `/bin/sh`. This ensures
  maximum portability and execution speed. Improve
  readability by adding a space after the
  interpreter path in [shebang] line:

``` bash
  #! /bin/sh
```

- Use 4 spaces for indentation.

- Use readable `--long` options where
  possible. Assume GNU utilities and require
  their installation in the README.
  **Rationale:** `--long` options make
  scripts easier to read and maintain. GNU
  utilities are more capable and generally
  optimized for speed.

- Use `"$quoted"` variables.

- Prefer `$var` by default. Use the
  braces only when necessary for boundary
  conditions (e.g., `${var}suffix`).

``` shell
    path="$dir/$to/$MY_FILE_NAME"
```

- In variable tests, use and simple
  notations. Avoid `-z` or `-n` [test]
  options.

``` bash
    [ "$var" ]    # Has value test
    [ ! "$var" ]  # No value test
```

- In functions, prefer names using
  [CamelCase]. Start identifier with an
  uppercase letter to minimize conflicts
  with existing commands. Use the standard
  POSIX parentheses syntax to define
  functions; avoid the Bash-only [function
  keyword]. Prefer including a space before
  the function parentheses `()` to match the
  output style of the [Bash type] command.

``` shell
    # POSIX-compatible syntax
    Example ()
    {
        # Use 'local' though not
        # strictly POSIX, it's
        # supported by virtually
        # all modern /bin/sh
        # implementations.

        local var="value"
    }
```

- Use the [Allman] "line up" style in
  `do..done`

``` shell
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
  their own lines. **Rationale:**
  Improves the visual flow and make the
  action blocks stand out.

```
    # Note: according to POSIX, $var does
    # need quoting
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

``` shell
    if <statement>; then
        ...
    fi

    # In longer statements, switch
    # to Allman style for more
    # clarity. Command is more
    # visually prominent (it stands
    # out better).

    if <this is an example of a very long statement>
    then
        ...
    fi
```

- Keep it simple.

``` shell
    # Use standard `if..fi`.
    # Avoid clever logical `&&` or `||`.
    # Complex blocks sacrifice
    # clarity for readers
    # unfamiliar with shell
    # shorthands.

    <statement> && {
        <code>
        <code>
        <code>
        <... and more code>
    }
```


## Bash rules

- Use the portable `env` [shebang] line.
  Improve readability by adding a space after
  the interpreter path.

``` shell
  #! /usr/bin/env bash
```

- Even in Bash, default to POSIX syntax
  unless Bash-specific features are
  required. **Rationale:** Ensures later
  compatibility with `/bin/sh`, allowing
  scripts to benefit from faster startup,
  fewer forks, and broader system
  portability. **Practical Guidance:**
  Avoid the Bash-specific
  [arithmetic expression] `((...))` and
  [double bracket] conditional expression
  `[[...]]`. Use the POSIX-style [test]
  `[...]` instead and always quote
  variable expansions. Developing a
  consistent quoting habit ensures
  safety, correctness, and portability.
  Examples:

``` shell
  # Instead of ...
  [[ $var = $value ]]

  # Use portable POSIX-style with
  # quoting
  [ "$var" = "$value" ]

  # Apply quoting consistently
  file="$path/$conf"
  result=$(command "$file")

  # - - - - - - - - - - - - - - -

  # Instead of ...
  for ((i=0; i < 10; i++))
  do
      ...
  done

  # Use portable POSIX-style
  i=0
  while [ "$i" -lt 10 ]
  do
      # Use POSIX arithmetic expansion
      # $() for iteration
      i=$((i + 1))
  done
```

## Local variable notes

**Note: Dynamic scope:** The shell uses
dynamic scoping to control a variable’s
visibility within functions. The shell
uses dynamic scoping (see [functions] in
Bash manual) to control a variable's
visibility within functions. This means
that a function can see variables defined
not just inside itself, but also
variables defined by any other function
that called it.

``` shell
    Two ()
    {
        echo "$var" # "hello"
    }

    One ()
    {
        local var="hello"
        Two
    }

    One
```

**Note for [Korn Shell]
compatibility**. If supporting BSD or UNIX
systems that may use `ksh` as `/bin/sh` is
required, include the necessary code at the
script's start to emulate the `local`
keyword.

``` shell
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
            # generate an error and
            # exit script.
            eval 'local () { typeset "$@"; }'
        fi
    fi
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

[arithmetic expression]: https://www.gnu.org/software/bash/manual/html_node/Shell-Arithmetic.html
[function keyword]: https://www.gnu.org/software/bash/manual/html_node/Shell-Functions.html
[functions]: https://www.gnu.org/software/bash/manual/html_node/Shell-Functions.html
[double bracket]: https://www.gnu.org/software/bash/manual/bash.html#ndex-_005b_005b
{conditional expression]: https://www.gnu.org/software/bash/manual/bash.html#Bash-Conditional-Expressions

[test]: https://pubs.opengroup.org/onlinepubs/9799919799/utilities/test.html
[bash type]: https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html#index-type
[type]: https://pubs.opengroup.org/onlinepubs/9799919799/utilities/type.html

[Korn Shell]: https://en.wikipedia.org/wiki/KornShell
[ksh]: https://en.wikipedia.org/wiki/KornShell

[shebang]: https://en.wikipedia.org/wiki/Shebang_(Unix)

<!-- END OF FILE -->
