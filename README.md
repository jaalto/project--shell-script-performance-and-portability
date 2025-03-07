# SHELL SCRIPT PERFORMANCE TESTS

How can you make shell scripts to run faster?
That's the question these test cases on aim to answer.

- [RESULTS](./doc/RESULTS.md)
- [RESULTS-BRIEF](./doc/RESULTS-BRIEF.txt)
- The test cases and code in [bin/](./bin/)
- [USAGE](./USAGE.md)
- [CONTRIBUTING](./CONTRIBUTING.md)

Consider the raw
[`time`](https://www.gnu.org/software/bash/manual/bash.html#Reserved-Words)
results only as guidance, as they reflect only
the system used at the time of testing.
Instead, compare the relative order in which
each test case produced the fastest results.

The results presented in this README provide
only some highlighs from the test cases. For the
full listing, see RESULTS above.

## The project structure

    bin/            The tests
    doc/            Results by "make doc"
    COPYING         License (GNU GPL)
    INSTALL         Install instructions
    USAGE.md        How to run the tests
    CONTRIBUTING.md Writing test cases

## Project details

- Homepage:
  https://github.com/jaalto/project--shell-script-performance

- To report bugs:
  see homepage.

- Source repository:
  see homepage.

- Depends:
  Bash, GNU coreutils

- Optional depends:
  GNU `make`. Used as
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

- If you have tasks that can be run concurrently, use
  [GNU parallel](https://www.gnu.org/software/parallel/) for massive gains in performance. See also how to use
  [semaphores](https://www.gnu.org/software/parallel/sem.html#understanding-a-semaphore)
  to wait for all concurrent tasks to finish
  before continuing with the rest of the tasks in
  the pipeline. In some cases, even parallelizing
  work with GNU
[`xargs --max-procs=0`](https://www.gnu.org/software/findutils/manual/html_node/find_html/xargs-options.html) can help.

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
  *Note*: If you need to process large data files,
  use a lot of regular expressions, manipulate or
  work on data extensively, there is probably
  nothing that can replace the speed of `perl`
  unless you go even lower-level languages like
  `C`. But then again, we assume that you know
  how to choose your tools in those cases.

```
    cmd | awk '{...}'

    # ... could probably
    # replace all of these
    cmd | head ... | cut ...
    cmd | grep ... | sed ...
    cmd | grep ... | grep -v ... | cut ...
```

- *Note*: if you have hordes of RAM,
  no shortage of cores, and big data files, then
  utilize pipelines `<cmd> | ...` as much as
  possible because the kernel will optimize
  things in memory better. In more powerful
  systems, many latency/performance issues are
  not as relevant.

- Use Shell
  [built-ins](https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html)
  and not binaries:

```
    echo     # not /usr/bin/echo
    printf   # not /usr/bin/printf
    [ ... ]  # not /usr/bin/test
```

# MAJOR PERFORMANCE GAINS

- It is about 20-70 times faster to do string
  manipulation in memory, than calling external
  utilities. Seeing the measurements just how
  expensive it is, reminds us to utilize the
  possibilities of
[parameter expansion](https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameter-Expansion) to their fullest;
  especially in loops.
  See [code](./bin/t-string-file-path-components-and-parameter-expansion.sh).

```
    str="/tmp/filename.txt.gz"

    # Almost instantaneous
    ext=${str#*.}  # Delete up till first "."

    # Over 50x slower
    ext=$(echo "$str" | cut --delimiter="." --fields=2,3)

    # Even worse, over 70x slower
    ext=$(echo "$str" | sed --regexp-extended 's/^[^.]+//')
```

- Is is about 40 times faster In functions
  to use Bash
  [nameref](https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameters)
  to return a value than with `ret=$(fn)`.
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
  expression tests on that string multiple
  times. This is much more efficient than calling
  `grep` command many times.
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

- It is about 2 times faster to prefilter with `grep`
  to process only certain lines
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
    done < <(grep --extended-regexp "$re" file)

    # Problem: while runs in
    # a separate environment
    grep --extended-regexp "$re" file) |
    while read -r ...
    do
        ...
    done

    # Slowest, in-loop prefilter
    while read -r line
    do
       [[ $line =~ $re ]] || continue
       ...
    done < file

```

# MODERATE PERFORMANCE GAINS

- It is about 4-5 times faster to split a string
  into an array using Bash list rather than
  here-string. This is because Bash
  [HERE STRING](https://www.gnu.org/software/bash/manual/bash.html#Here-Strings)
  `<<<` uses a
  pipe or temporary file, whereas Bash list
  operates entirely in memory. The pipe
  buffer behavor was introduced in
  [Bash 5.1 section c](https://github.com/bminor/bash/blob/master/CHANGES).
  *Warning*: Please note that using the `(list)`
  statement will undergo pathname expansion.
  Use it only in situations where the string
  does not contain any globbing characters
  like `*`, `?`, etc. The pathname expansion
  can be disabled with
  `set -f; ...code...; set +f`.
  To disable it locally in a function,
  use statement `local - set -f`.
  See [code](./bin/t-variable-array-split-string.sh).

```
    # Prepare a string with
    # 100 "words"
    printf -v string "%s:" {1..100}

    # Fastest
    saved=$IFS
    IFS=":"
    array=($string)
    IFS=$saved

    # In function temporarily disable
    # pathname expansion (-f)
    fn()
    {
        local - set -f
        ...
        local saved=$IFS
        IFS=":"
        array=($string)
        IFS=$saved
        ...
    }

    # One liner but much slower
    IFS=":" read -ra array <<< "$string"

    # In Linux, to see what Bash uses
    # for HERE STRING: pipe or
    # temporary file
    bash -c 'ls -lL /proc/self/fd/0 <<< hello'
```

# MINOR PERFORMANCE GAINS

According to the results, none of
these offer real practical benefits. See the
[results](./doc/RESULTS.md)
for details and further commentary.

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

# NO PERFORMANCE GAINS

None of these offer any advantages to speed up shell scripts.

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
  minuscule advantage, but it may be impractical
  because `N..M` cannot be parameterized.
  Surprisingly, the simple and elegant `$(seq M)`
  is fast, even though
  [command substitution](https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html#Command-Substitution)
  uses a subshell. We can only guess that the
  reason is that any kind of looping, increments,
  and tests are inherently slow. The last POSIX
  `while` loop example was slightly slower in all
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
  a `perl` program,
  makes things notably slower for typical file
  sizes. Otherwise, GNU `parallel` is
  excellent for making full use of multiple
  cores. The idea of splitting a file into
  chunks of lines and running the search in
  parallel is intriguing, but the overhead of
  starting perl with `parallel` is orders of
  magnitude more expensive compared to running
  already optimized `grep` only once.
  Based on StackOverflow discussions,
  if file sizes are in the tens of megabytes,
  GNU `parallel` can help speed things up.
  See [code](./bin/t-command-grep-parallel.sh).

```
    parallel --pipepart grep "$re" < "$megafile"
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

# FURTHER READING

- See Greg's Bash Wiki and FAQ
  https://mywiki.wooledge.org/BashGuide
- List of which features were added to specific
  releases of Bash
  https://mywiki.wooledge.org/BashFAQ/061
- See BashFAQ why
  [POSIX \$(cmd)](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_03)
  is preferrable over archaic backtics as in \`cmd\`.
  https://mywiki.wooledge.org/BashFAQ/082
**Note**: for 20 years even all the `sh` shells
  have supported the readable `$()`command
  substitution syntax. This includes very
  conservarive HP-UX and Solaris 10 from 2005 whose
  support ended in
  [2021](https://www.liquisearch.com/solaris_operating_system/version_history).
- Lint scripts for potential mistakes with
  https://www.shellcheck.net. In Debian,
  install package "shellcheck" and see
  https://manpages.debian.org/testing/shellcheck/shellcheck.1.en.html
- In Debian, to help to write portable POSIX
  scripts, install package "devscripts" and see
  https://manpages.debian.org/testing/devscripts/checkbashisms.1.en.html

For the curious readers:

- Details how the
  [`read`](https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html#index-read)
  command works
  https://unix.stackexchange.com/a/209184
- Super simple `s` command interpreter to write
  shell-like scripts (security oriented):
  https://github.com/rain-1/s

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

Keywords: shell, sh, POSIX, bash, programming,
optimize, performance, profiling
