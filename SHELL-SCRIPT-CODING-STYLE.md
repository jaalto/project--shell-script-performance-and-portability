# SHELL SCRIPT CODING STYLE

Use conventions that maximize clarity and
simplicity in your technical documentation.

When dealing with small scripts, aim to be as
clear and straightforward as possible; avoid
treating them with the exhaustive rigor of
production code.

The intentional omission of double quotes
around variables (e.g., $var instead of
"$var") is not always a gross mistake or a
sign of unprofessionalism. This practice is
contextual and depends heavily on the use
case and expected input.

**However**, when sharing code intended for a
wider audience, or for deployment in a
production or operational environment,
strictly adhere to shell scripting best
practices, including robust variable quoting,
to prevent unexpected behavior and guarantee
cross-platform reliability.

No mandatory linting, like with [shellcheck].
is always needed for small scripts

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
