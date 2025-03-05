# SHELL SCRIPT PERFORMANCE TESTS

How to write faster and optimized shell scripts?

That's the question these tests try to answer.
See files:

- [RESULTS](./doc/RESULTS.txt)
- [RESULTS-BRIEF](./doc/RESULTS-BRIEF.txt)
- The test cases and code in [bin/](./bin/)
- [USAGE](./USAGE.md)
- [CONTRIBUTING](./CONTRIBUTING)

This project includes tests to determine the
most efficient way to write shell script.

Consider the raw
[`time`](https://www.gnu.org/software/bash/manual/bash.html#Reserved-Words)
results only as guidance, as they reflect only
the system used at the time of testing.
Instead, compare the relative order in which
each test case produced the fastest results.

## The project structure

        bin/          The tests
        doc/          Results generated by "make doc"
        COPYING       License file (GNU GPL)
        INSTALL       Install instructions
        USAGE.md      How to run the tests
        CONTRIBUTING  Writing more tests shell scripts

## Project details

- Homepage:
  https://github.com/jaalto/project--shell-script-performance

- To report bugs:
  see homepage.

- Source repository:
  see homepage.

- Depends:
  Bash and POSIX shell.

- Optional depends:
  `make` (any version). Used as
  a frontend to call utilities.

# MAJOR PERFORMANCE GAINS

- Minimize extra processes as much as possible.
  In most cases, a single
  [awk](https://www.gnu.org/software/gawk/)
  can handle all of `sed`, `cut`, `grep` etc.
  chains. The `awk` binary program is *very*
  fast and more efficient than
  [perl](https://www.perl.org)
  or
  [python](https://www.python.org)
  scripts where startup time and higher
  memory consumption is a factor.

```
    cmd | awk '{...}'

    # ... Avoid
    cmd | head ... | cut ...
    cmd | grep ... | sed ...
```

- Use Shell
  [built-ins](https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html)
  and not binaries:

```
    echo ...    # not /usr//bin/echo
    printf ...  # not /usr/bin/printf
    [ ... ]     # not /usr//bin/test
```

- In functions, using Bash
  [nameref](https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameters)
  to return a value is about 40 times faster
  than `ret=$(fn)`.
  See [code](./bin/t-function-return-value.sh).

```
    fn()
    {
        local -n retref=$1  # nameref
        shift
        local arg=$1

        retref="value"
    }

    # return value in 'ret'
    fn ret "arg"
```

- For line-by-line handling, read the file into an
  array and then loop through the array. If you're
  wondering about
  [`readarray`](https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html#index-readarray)
  vs `mapfile`, there is no difference.
  See [code](./bin/t-file-read-content-loop.sh).

```
    readarray -t array < file

    for i in "${array[@]}"
    do
        ...
    done

    # This would be 2x slower

    while read -r ...
    do
        ...
    done < FILE
```

- To process only certain lines, use a prefilter
  with grep instead of reading the whole file
  into a loop and then selecting lines. Bash loops
  are generally slow. The
  [process substitution](https://www.gnu.org/software/bash/manual/html_node/Process-Substitution.html)
  is more general because variables persist after the loop,
  whereas the `<loop>` in the `while | <loop>` runs in
  a separate shell due to the pipe.
  See [code](./bin/t-command-output-vs-process-substitution.sh).

```
    while read -r ...
    do
        ...
    done < <(grep -E "$re" "$file")

    # Slightly slower
    while read -r ...
    do
       if [[ ! <match> ]]; then
           continue
       fi

       ...
    done < "$file"

```

- It is faster to read a file into memory as a
  string and use Bash regular expression tests
  on that string. This is much more efficient
  than calling the external `grep` command.
  See [code](./bin/t-file-grep-vs-match-in-memory.sh).

```
   # Suppose 100 KiB buffer is enough
   read -N$((100 * 1024)) < "$file"

   if [[ $REPLY =~ $regexp1 ]]; then
       ...
   elif [[ $REPLY =~ $regexp2 ]]; then
       ...
   fi
```

# MODERATE PERFORMANCE GAINS

- To split a string into an array, use `eval`,
  which is 2-3 times faster than using a
  here-string. This is because Bash
  [HERE STRING](https://www.gnu.org/software/bash/manual/bash.html#Here-Strings)
  `<<<` uses a
  pipe or temporary file, whereas `eval`
  operates entirely in memory. The pipe
  buffer behavor was introduced in
  [Bash 5.1 section c](https://github.com/bminor/bash/blob/master/CHANGES).
  See [code](./bin/t-variable-array-split-string.sh).

```
    # Fastest
    string=$(echo {1..100})
    eval 'array=($string)'

    # Much slower
    read -ra array <<< "$string"

    # To see what Bash uses for HERE STRING
    bash -c 'ls -lL /proc/self/fd/0 <<<hello'
```

# MINOR PERFORMANCE GAINS

According to the tests, note that none of
these offer real practical benefits. See the
raw test results for details and further
commentary.

- One might think that choosing optimized `grep`
  options would make a difference. According to the
  benchmarks for typical files, they don't:
  in practice, performance is nearly identical even with the ignore case
  option included.
  Nonetheless, there may be cases where selecting
  `LANG=C`, using `--fixed-strings`, and avoiding
  `--ignore-case` might improve performance, at least
  according to some StackOverflow discussions with
  huge data files.
  See [code](./bin/t-command-grep.sh).

```
    # The same performance. Regexp engine
	# does not seem to be the bottleneck
	LANG=C grep --fixed-strings ...
	LANG=C grep --extended-regexp ...
	LANG=C grep --perl-regexp ...
	LANG=C grep <any of above> --ignore-case ...
```

- The Bash-specific `[[ ]]` might offer a
  minuscule advantage but only in loops of
  10,000 iterations. Unless the safeguards
  provided by Bash `[[ ]]` are important, the
  POSIX test will do fine.
  See [code](./bin/t-statement-if-test-posix-vs-bash.sh).

```
    [ "$var" = "1" ] # POSIX
    [[ $var = 1 ]]   # Bash

    [ ! "$var" ]     # POSIX
    [[ ! $var ]]     # Bash
    [ -z "$var" ]    # archaic (POSIX)
```

- There are no practical differences between these.
  The POSIX statement will do fine.
  See [code](./bin/t-statement-arithmetic-increment.sh).

```
    i=$((i + 1))     # POSIX
    : $((i++))       # POSIX, Uhm...
    ((i++))          # Bash
    let i++          # Bash
```

- The Bash-specific `{N..M}` might offer a
  minuscule advantage, but it may be impractical
  because `N..M` cannot be parameterized.
  Surprisingly, the simple and elegant winner by
  a hair is `$(seq M)`, even though it calls a
  subshell with a binary. We can only guess that
  the reason is that any kind of looping,
  increments, and tests are inherently slow. The
  POSIX `while` loop variant was slightly slower
  in all subsequent tests.
  See [code](./bin/t-statement-arithmetic-for-loop.sh).

```
    for i in {1..100}  # Bash
    do
	    ...
    done

    for i in $(seq $N) # binary, still fast
    do
	    ...
    done

    for ((i=0; i < $N; i++)) # Bash
    do
	    ...
    done

    while [ "$i" -le "$N" ] # POSIX
    do
	    i=$((i + 1))
    done
```

# NO PERFORMANCE GAINS

None of these offer any advantages to speed up shell scripts.

- There is no performance difference between a
  regular loop and a
  [process substitution](https://www.gnu.org/software/bash/manual/html_node/Process-Substitution.html)
  loop. However, the latter is more general, as
  any variable set during the loop will persist
  after the loop because all statements run in
  the same environment.
  See [code](./bin/t-command-output-vs-process-substitution.sh).

```
    while read -r ...
    do
        ...
    done < <(command)

    # while is not in the same environment
    command |
    while read -r ...
    do
        ...
    done
```

- With `grep`, the use of
  [GNU parallel](https://www.gnu.org/software/parallel/),
  a `perl` script,
  makes things notably slower for typical file sizes.
  Otherwise, GNU `parallel` is excellent for making
  full use of multiple cores. The idea of splitting a
  file into chunks of lines and running the search in
  parallel is intriguing, but the overhead of
  starting perl with `parallel` is orders of magnitude more
  expensive compared to `grep` binary.
  Based on StackOverflow discussions, if file sizes are
  in the tens of megabytes, GNU `parallel` can help
  speed things up.
  See [code](./bin/t-command-grep-parallel.sh).

```
    parallel --pipepart grep "$re" < "$big_file"
```

# RANDOM NOTES

See the
[Bash](https://www.gnu.org/software/bash/manual/bash.html#index-TIMEFORMAT)
manual page how to use `time`
command to display results in different formats:

        TIMEFORMAT='real: %R'  # '%R %U %S'

You could also drop kernel cache before testing:

        echo 3 > /proc/sys/vm/drop_caches

# COPYRIGHT

Copyright (C) 2024-2025 Jari Aalto

# LICENSE

These programs are free software; you can redistribute it and/or modify
them under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

These programs are distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with these programs. If not, see <http://www.gnu.org/licenses/>.

License: GPL-2-or-later - https://spdx.org/licenses

Keywords: shell, sh, posix, bash, programming,
optimize, performance, profiling
