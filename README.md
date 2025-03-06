# SHELL SCRIPT PERFORMANCE TESTS

How to write faster and optimized shell
scripts?

That's the question these tests try to answer.
See files:

- [RESULTS](./doc/RESULTS.txt)
- [RESULTS-BRIEF](./doc/RESULTS-BRIEF.txt)
- The test cases and code in [bin/](./bin/)
- [USAGE](./USAGE.md)
- [CONTRIBUTING](./CONTRIBUTING.md)

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
    doc/          Results by "make doc"
    COPYING       License (GNU GPL)
    INSTALL       Install instructions
    USAGE.md      How to run the tests
    CONTRIBUTING  Writing test cases

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

# GENERAL ADVICE

- If you run scripts on many small files, set
  up a RAM disk and copy the files to it. This
  can lead to massive speed gains. See
  [tmpfs](https://en.wikipedia.org/wiki/Tmpfs),
  which allows you to set a size limit, unlike
  the memory-hogging
  [ramfs](https://wiki.debian.org/ramfs),
  which can fill all available memory and
  potentially halt your server.

- If you know the files beforehand, preload
  them into memory. This can also lead to
  massive speed gains.
  See [vmtouch](https://hoytech.com/vmtouch/).

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
    echo     # not /usr/bin/echo
    printf   # not /usr/bin/printf
    [ ... ]  # not /usr/bin/test
```

# MAJOR PERFORMANCE GAINS

- In functions, using Bash
  [nameref](https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameters)
  to return a value is about 40 times faster
  than `ret=$(fn)`.
  See [code](./bin/t-function-return-value.sh).

```
    fn()
    {
        # Use nameref for the
        # return value
        local -n retref=$1
        shift
        local arg=$1

        retref="value"
    }

    # return value in 'ret'
    fn ret "arg"
```

- It is about 10 times faster to read a file
  into memory as a string and use Bash regular
  expression tests on that string. This is
  much more efficient than calling the
  external `grep` command.
  See [code](./bin/t-file-grep-vs-match-in-memory.sh).

```
   # 100 KiB buffer
   read -N$((100 * 1024)) < file

   if [[ $REPLY =~ $regexp1 ]]; then
       ...
   elif [[ $REPLY =~ $regexp2 ]]; then
       ...
   fi
```

- It is about 2 times faster to for
  line-by-line handling to read the file into
  an array and then loop through the array.
  If you're wondering about
  [`readarray`](https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html#index-readarray)
  vs `mapfile`, there is no difference.
  See [code](./bin/t-file-read-content-loop.sh).

```
    readarray -t array < file

    for i in "${array[@]}"
    do
        ...
    done

    # Slower
    while read -r ...
    do
        ...
    done < FILE
```

- To process only certain lines, use a
  prefilter with grep (about 2 times faster)
  instead of reading the whole file
  into a loop and then selecting lines. Bash
  loops are generally slow. The
  [process substitution](https://www.gnu.org/software/bash/manual/html_node/Process-Substitution.html)
  is more general because variables persist after the loop,
  whereas the `<loop>` in the `while | <loop>` runs in
  a separate shell due to the pipe.
  See [code](./bin/t-file-read-match-lines-loop-vs-grep.sh).

```
    while read -r ...
    do
        ...
    done < <(grep -E "$re" file)

    # Slower, in-loop filter
    while read -r ...
    do
       if [[ ! <match> ]]; then
           continue
       fi

       ...
    done < file

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

    # To see what Bash uses
    # for HERE STRING: pipe or
    # temporary file
    bash -c 'ls -lL /proc/self/fd/0 <<< hello'
```

# MINOR PERFORMANCE GAINS

According to the tests, note that none of
these offer real practical benefits. See the
raw test results for details and further
commentary.

- One might think that choosing optimized
  `grep` options would make a difference.
  In practice, performance is nearly identical
  even with the ignore case option included.
  Nonetheless, there may
  be cases where selecting `LANG=C`, using
  `--fixed-strings`, and avoiding
  `--ignore-case` might improve performance,
  at least according to StackOverflow
  discussions with   huge data files.
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
  POSIX tests will do fine.
  See [code](./bin/t-statement-if-test-posix-vs-bash.sh).

```
    [ "$var" = "1" ] # POSIX
    [[ $var = 1 ]]   # Bash

    [ ! "$var" ]     # POSIX
    [[ ! $var ]]     # Bash
    [ -z "$var" ]    # archaic
```

- There are no practical differences between
  these. The POSIX `$(())` statement
  will do fine. Note that the odd-looking
  [`:`](https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html)
  utilizes the true operator's side effect
  and therefore may not be the most
  readable option.
  See [code](./bin/t-statement-arithmetic-increment.sh).

```
    i=$((i + 1))     # POSIX
    : $((i++))       # POSIX, Uhm
    ((i++))          # Bash
    let i++          # Bash
```

- The Bash-specific `{N..M}` might offer a
  minuscule advantage, but it may be
  impractical because `N..M` cannot be
  parameterized. Surprisingly, the simple and elegant
  `$(seq M)` is fast, even though it calls a
  subshell with a binary. We can only guess
  that the reason is that any kind of
  looping, increments, and tests are
  inherently slow. The last POSIX `while` loop
  example was slightly slower in all
  subsequent tests.
  See [code](./bin/t-statement-arithmetic-for-loop.sh).

```

    N=1
    M=100

    # Bash
    for i in {1..100}
    do
        ...
    done

    # seq binary, still fast
    for i in $(seq $M)
    do
        ...
    done

    # Bash, slow
    for ((i=$N; i <= $M; i++))
    do
        ...
    done

    # POSIX, slowest
    i=$N
    while [ "$i" -le "$M" ]
    do
        i=$((i + 1))
    done
```

# NO PERFORMANCE GAINS

None of these offer any advantages to speed up shell scripts.

- There is no performance difference between a
  regular loop and a
  [process substitution](https://www.gnu.org/software/bash/manual/html_node/Process-Substitution.html)
  loop. However, the latter is more general,
  as any variable set during the loop will
  persist after the loop because all
  statements run in the same environment.
  See [code](./bin/t-command-output-vs-process-substitution.sh).

```
    while read -r ...
    do
        ...
    done < <(command)

    # while is not being run
    # in the same environment
    command |
    while read -r ...
    do
        ...
    done
```

- With `grep`, the use of
  [GNU parallel](https://www.gnu.org/software/parallel/),
  a `perl` script,

  makes things notably slower for typical file
  sizes. Otherwise, GNU `parallel` is
  excellent for making full use of multiple
  cores. The idea of splitting a file into
  chunks of lines and running the search in
  parallel is intriguing, but the overhead of
  starting perl with `parallel` is orders of
  magnitude more expensive compared to `grep`
  binary. Based on StackOverflow discussions,
  if file sizes are in the tens of megabytes,
  GNU `parallel` can help speed things up.
  See [code](./bin/t-command-grep-parallel.sh).

```
    parallel --pipepart grep "$re" < "$big_file"
```

# RANDOM NOTES

See the
[Bash](https://www.gnu.org/software/bash/manual/bash.html#index-TIMEFORMAT)
manual page how to use `time`
command to display results in different
formats:

        TIMEFORMAT='real: %R'  # '%R %U %S'

You could also drop kernel cache before
testing:

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
