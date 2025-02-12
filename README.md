# SHELL SCRIPT PERFORMANCE TESTS

How to write faster and optimized shell scripts?

That's the question these tests try to answer.
See the results:

- [RESULTS](./doc/RESULTS.txt)
- [RESULTS-BRIEF](./doc/RESULTS-BRIF.txt)
- The test cases and code in [bin/](./bin/)

This project includes tests to determine the
most efficient way to write shell script code.

Consider the raw `time(1)` results only as
guidance, as they reflect the system used.
Instead, compare the relative order in which
each test case produced the fastest results.

## The file structure

```
bin/      The tests
RESULTS*  Generated; "make doc"
COPYING   GPL-2-or-later
INSTALL   Install instructions
```

## Project details

- Homepage:
  https://github.com/jaalto/project--shell-script-performance

- To report bugs:
  see homepage.

- Source code repository:
  see homepage.

- Depends:
  Bash and POSIX shell.

- Optional Depends:
  `make` (any version). Used as
  a frontend to call utilities.

# MAJOR PERFORMANCE GAINS

- Avoid extra processes at all costs:

  `cmd | head .. | ... | cut ...`
  `cmd | grep ... | sed ...`

  Instead, a single `awk` probably handles
  all of the above. The `awk` is *very*
  fast and efficient for any tasks:

  `cmd | awk '{...}'`

- Use built-ins. No path names to binaries:

```
    echo ...    # not /bin/echo
    printf ...  # not /bin/printf
    [ ... ]     # not: if /bin/test ...; then ...
```

- In functions, use of nameref (Bash) to return value
  is about 40x faster than `ret=$(fn)`. Use this:

```
    fn()
    {
        local -n retval=$1  # VAR name where to save
        shift               # real arguments follow
        local arg=$1

        retval="value"      # Assigns to indirect var
    }

    ret=""
    fn ret "arg" ...  # returns stored in 'ret'
```

- For line-to-line handling, read file
  into an array and then loop the array:

  `readarray -t array < file ; for i in "${array[@]}" ...`

  which is much faster than doing:

  `while read ... done < FILE`.

- To process only certain lines,
  use prefilter grep as in:

  `while read -r ...done < <(grep)`.

  That will be much faster than excluding or
  picking lines inside loop with `contine` or
  `if...fi`.

- It is faster to Read file into memory as a
  STRING and use bash regexp tests on STRING.
  This is much more efficient than calling
  external `grep(1)`.

TODO:

# MODERATE PERFORMANCE GAINS

- To split a string into an array, use `eval`,
  which is much faster than the here-string. The
  reason is probably that `<<<` uses a temporary
  file, whereas `eval` operates entirely in
  memory.

```
    string=$(echo {1..100})
    eval 'array=($string)'
    # ... the following would be much slower
    read -ra array <<< "$string"
```

TODO

# NEGLIGIBLE OR NO PERFORMANCE GAINS

According to the tests, there is not really a
difference between the following examples. See
the raw test results for details and further
commentary.

- The Bash specific `[[ ]]` might offer
  a tad minuscle advantage.

```
    [ "$var" = "1" ] # POSIX
    [[ $var = 1 ]]   # Bash

    [ ! "$var" ]     # POSIX
    [[ ! $var ]]     # Bash
    [ -z "$var" ]    # archaic
```

- There are no differences between these:

```
    : $((i++))       # POSIX
    i=$((i + 1))     # POSIX
    ((i++))          # Bash
    let i++          # Bash
```

- The Bash-specific `{1..N}` might offer a
  minuscule advantage, but it's impractical
  because `N` cannot be parameterized.
  Surprisingly, a simple and elegant winner by a
  hair is `$(seq N)`. The POSIX `while`-loop
  variant was slightly slower in all subsequent
  tests.

```
    for i in {1..$N} ...
    for i in $(seq $N) ...
    for ((i=0; i < $N; i++)) ...
    while [ "$i" -le "$N" ]; do ... i=$((i + 1)) .. done
```

# RANDOM NOTES

See bash(1) manual how to use `time` command
to display results in different formats:

```
TIMEFORMAT='real: %R'  # '%R %U %S'
```

You could also drop kernel cache before testing:

```
echo 3 > /proc/sys/vm/drop_caches
```

# COPYRIGHT

Copyright (C) 2024-2025 Jari Aalto

# LICENSE

These programs are free software; you can
redistribute and/or modify the programs under the
terms of GNU General Public license either
version 2 of the License, or (at your option)
any later version.

Keywords: shell, sh, posix, bash, programming,
optimize, performance, profiling
