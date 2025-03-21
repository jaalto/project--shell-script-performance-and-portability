<!--
Github Markdown Guide: https://is.gd/nqSonp
VSCode: preview markdown C-S-v
-->

# SHELL SCRIPT PERFORMANCE AND PORTABILITY

How can you make shell scripts portable and run faster?
That are the questions these test cases aim to answer.

The tests reflect results under Linux.
The main focus is on the features found in
[Bash](https://www.gnu.org/software/bash)
rather than minimalistic `sh`
[POSIX 2018](https://pubs.opengroup.org/onlinepubs/9699919799/)
shells;
see also POSIX in
[Wikipedia](https://en.wikipedia.org/wiki/POSIX).

> Please note that `sh` here refers to
> modern, best-of-effort POSIX-compatible,
> minimal shells like
> [dash](https://tracker.debian.org/pkg/dash) and
> [posh](https://tracker.debian.org/pkg/posh).
> See section
> [ABOUT POSIX, SHELLS AND PORTABILITY](#about-posix-shells-and-portability).

In Linux like systems, from a performance point
of view, for serious shell scripting, Bash is
the sensible choice for efficient data
manipulation in memory with arrays and strings
with an extended set of parameter
expansions, regular expressions, including
extracting regex matches and utilizing fast
functions with namerefs.

In other operating systems, for example BSD,
the obvious choice for shell scripting would be
fast
[Ksh](https://en.wikipedia.org/wiki/KornShell)
([ksh93](https://tracker.debian.org/pkg/ksh93u+m),
[mksh](https://tracker.debian.org/pkg/mksh),
etc.), unless an
extended set of features only found in Bash are
needed.

Shell scripting is about combining redirections,
pipes, calling external utilities, and gluing them
all together. Shell scripts are also quite
portable by default, requiring no additional
installation.
[Perl](https://www.perl.org)
or
[python](https://www.python.org)
excel in their
respective fields, where the requirements differ
from those of the shell.

The results presented in this README provide
only some highlighs from the test cases
listed in RESULTS. Consider the raw
[`time`](https://www.gnu.org/software/bash/manual/bash.html#Reserved-Words)
results only as guidance, as they reflect only
the system used at the time of testing.
Instead, compare the relative order in which
each test case produced the fastest results.


- [RESULTS](./doc/RESULTS.md)
- [RESULTS-BRIEF](./doc/RESULTS-BRIEF.txt)
- The test cases and code in [bin/](./bin/)
- [USAGE](./USAGE.md)
- [CONTRIBUTING](./CONTRIBUTING.md)

Table of Contents

- [GENERAL ADVICE](#general-advice)
- [MAJOR PERFORMANCE GAINS](#major-performance-gains)
- [MODERATE PERFORMANCE GAINS](#moderate-performance-gains)
- [MINOR PERFORMANCE GAINS](#minor-performance-gains)
- [NO PERFORMANCE GAINS](#no-performance-gains)
- [ABOUT POSIX, SHELLS AND PORTABILITY](#about-posix-shells-and-portability)
- [RANDOM NOTES](#random-notes)
- [FURTHER READING](#further-reading)
- [COPYRIGHT](#copyright)
- [LICENSE](#license)

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

- **Depends**:
  Bash, GNU coreutils, file
  /usr/share/dict/words
  (Debian package: wamerican).

- **Optional depends**:
  GNU make for Makefile.
  For some tests: GNU parallel.

- Other requirements: the `time`
  command must be cabable of operating
  on functions. The Zsh's built-in `time`
  and the external time(1) command
  cannot time functions.

# GENERAL ADVICE

Regardless of the shell you use for scripting
([sh](https://tracker.debian.org/pkg/dash),
[ksh](https://tracker.debian.org/pkg/ksh93u+m),
[bash](https://www.gnu.org/software/bash)),
consider these factors.

- If you run scripts on many small files, set
  up a RAM disk and copy the files to it. This
  can lead to massive speed gains. In Linux, see
  [tmpfs](https://en.wikipedia.org/wiki/Tmpfs),
  which allows you to set a size limit, unlike
  the memory-hogging
  [ramfs](https://wiki.debian.org/ramfs),
  which can fill all available memory and
  potentially halt your server.

- If you know the files beforehand, preload
  them into memory. This can also lead to
  massive speed gains.
  In Linux, see [vmtouch](https://hoytech.com/vmtouch/).

- If you have tasks that can be run concurrently,
  use
  [Perl](https://www.perl.org)
  based
  [GNU parallel](https://www.gnu.org/software/parallel/) for massive gains in performance. See also how to use
  [semaphores](https://www.gnu.org/software/parallel/sem.html#understanding-a-semaphore)
  ([tutorial](https://www.gnu.org/software/parallel/parallel_examples.html#example-working-as-mutex-and-counting-semaphore))
  to wait for all concurrent tasks to finish
  before continuing with the rest of the tasks in
  the pipeline. In some cases, even parallelizing
  work with GNU
[`xargs --max-procs=0`](https://www.gnu.org/software/findutils/manual/html_node/find_html/xargs-options.html) can help.

- Minimize extra processes as much as possible.
  In most cases, a single
  [awk](https://www.gnu.org/software/gawk/)
  can handle all of
  [`sed`](https://www.gnu.org/software/sed/),
  [`cut`](https://www.gnu.org/software/coreutils/manual/html_node/index.html),
  [`grep`](https://www.gnu.org/software/grep/)
  etc.
  chains. The `awk` binary program is *very*
  fast and more efficient than
  [Perl](https://www.perl.org)
  or
  [Python](https://www.python.org)
  scripts where startup time and higher
  memory consumption is a factor.
  *Note*: If you need to process large files,
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
  no shortage of cores, and large files, then
  utilize pipelines `<cmd> | ...` as much as
  possible because the Linux Kernel will optimize
  things in memory better. In more powerful
  systems, many latency and performance issues are
  not as relevant.

- Use Bash Shell
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
  possibilities of basic `#` `##` `%` `%%`
[parameter expansions](https://pubs.opengroup.org/onlinepubs/009604499/utilities/xcu_chap02.html#tag_02_06_02)
and more in [Bash](https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameter-Expansion)
  to their fullest.
  See [code](./bin/t-string-file-path-components-and-parameter-expansion.sh).

```
    str="/tmp/filename.txt.gz"

    # Almost instantaneous
    # Delete up till first "."
    ext=${str#*.}

    # Over 50x slower
    ext=$(echo "$str" | cut --delimiter="." --fields=2,3)

    # Over 70x slower
    ext=$(echo "$str" | sed --regexp-extended 's/^[^.]+//')
```

- In Bash, using `ret=$(fn)` to call functions
  is very slow. On the other hand, in Ksh shells
  that would be fast. Therefore in Bash scrips,
  it is about 8 times faster, to use
  [nameref](https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameters)
  to return a value.
  See [code](./bin/t-function-return-value.sh).

```
    fnPosix() # dash
    {
        # Use nameref for the
        # return value
        local retref=$1
        shift
        local arg=$1

        eval "$retref=\$arg"
    }

    fnBash()
    {
        # Use nameref for the
        # return value
        local -n retref=$1
        shift
        local arg=$1

        retref=$arg
    }

    # Return value in 'ret'
    fnPosix ret "arg"
    fnBash ret "arg"
```

- It is about 10 times faster to read a file
  into memory as a string and use
  [pattern matching](https://www.gnu.org/software/bash/manual/bash.html#Pattern-Matching)
  or Bash regular expressions
  binary operator
  [`=~`](https://www.gnu.org/software/bash/manual/bash.html#index-_005b_005b)
  on string. In-memory handling is much more
  efficient than calling the `grep` command on a
  file, especially if multiple matches are
  needed.
  See [code](./bin/t-file-grep-vs-match-in-memory.sh).

```
   # Read max 100 KiB to $REPLY
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
  vs
  [`mapfile`](https://www.gnu.org/software/bash/manual/bash.html#index-mapfile),
  there is no difference.
  Built-in `readarray`is a synonym for `mapfile`.
  See [code](./bin/t-file-read-content-loop.sh).

```
    # Bash
    readarray -t array < file

    for line in "${array[@]}"
    do
        ...
    done

    # POSIX. Slower
    while read -r line
    do
        ...
    done < file
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
    # Bash
    while read -r ...
    do
        ...
    done < <(grep "$re" file)

    # POSIX
    # Problem: while runs in
    # a separate environment
    grep "$re" file) |
    while read -r ...
    do
        ...
    done

    # POSIX
    # Problem: Slow, extra call
    # required to delete tmpfile
    grep "$re" file) > tmpfile
    while read -r ...
    do
        ...
    done < tmpfile
    rm tmpfile

    # Bash, Slowest,
    # in-loop prefilter
    while read -r line
    do
       [[ $line =~ $re ]] || continue
       ...
    done < file

```

# MODERATE PERFORMANCE GAINS

- It is about 5 times faster to split a string
  into an array using list rather than
  using Bash here-string. This is because
  [HERE STRING](https://www.gnu.org/software/bash/manual/bash.html#Here-Strings)
  `<<<` uses a
  pipe or temporary file, whereas Bash list
  operates entirely in memory. The pipe
  buffer behavor was introduced in
  [Bash 5.1 section c](https://github.com/bminor/bash/blob/master/CHANGES).
  *Warning*: Please note that using the `(list)`
  statement will undergo pathname expansion
  so globbing characters
  like `*`, `?`, etc. in string would be a problem.
  The pathname expansion
  can be disabled with
  `set -f; ...code...; set +f`.
  See [code](./bin/t-variable-array-split-string.sh).

```
    str="1:2:3"

    # Bash, Ksh. Fastest.
    IFS=":" eval 'array=($str)'

    fn() # Bash
    {
        local str=$1

        # Make 'set' local
        local -

        # Disable pathname
        # expansion
        set -f

        local -a array

        IFS=":" eval 'array=($str)'
        ...
    }

    # Bash. Slower than 'eval'.
    IFS=":" read -ra array <<< "$str"

    # In Linux, see what Bash uses
    # for HERE STRING: pipe or
    # temporary file
    bash -c 'ls -l --dereference /proc/self/fd/0 <<< hello'
```

# MINOR PERFORMANCE GAINS

According to the results, none of
these offer practical benefits. See the
[results](./doc/RESULTS.md)
for details and further commentary.

- The Bash
  [brace expansion](https://www.gnu.org/software/bash/manual/bash.html#Brace-Expansion) `{N..M}` might offer a
  minuscule advantage, but it may be impractical
  because `N..M` cannot be parameterized.
  Surprisingly, the simple and elegant `$(seq N M)`
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

    # POSIX, fast
    for i in $(seq $N $M)
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

- One might think that choosing optimized
  `grep` options would make a difference.
  In practice, for typical file sizes
  (below few Megabytes),
  performance is nearly identical
  even with the ignore case option included.
  Nonetheless, there may
  be cases where selecting `LANG=C`, using
  `--fixed-strings`, and avoiding
  `--ignore-case` might improve performance,
  at least according to StackOverflow
  discussions with large files.
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

- The Bash-specific
  [`[[ ]]`](https://www.gnu.org/software/bash/manual/bash.html#index-_005b_005b)
  might offer a
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
  these. The POSIX
  [arithmetic expansion](https://www.gnu.org/software/bash/manual/bash.html#Arithmetic-Expansion)
  `$(())`
  compound command
  will do fine. Note that the odd-looking
  null command
  [`:`](https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html)
  utilizes the command's side effect
  to "do nothing, but evaluate elements"
  and therefore may not be the most
  readable option.
  See [code](./bin/t-statement-arithmetic-increment.sh).

```
    i=$((i + 1))     # POSIX (use this)
    : $((i++))       # POSIX, Uhm
    : $((i = i + 1)) # POSIX, Uhm!
    ((i++))          # Bash, Ksh
    let i++          # Bash, Ksh
```

- There is no performance
  difference between a
  regular while loop and a
  [process substitution](https://www.gnu.org/software/bash/manual/html_node/Process-Substitution.html)
  loop. However, the latter is more general,
  as any variable set during the loop will
  persist after *and* there is no need to clean
  up temporary files like in POSIX (1) solution.
  The POSIX (1) loop is marginally faster but
  the speed gain is lost by the extra `rm` command.
  See [code](./bin/t-command-output-vs-process-substitution.sh).

```

    # Bash, Ksh
    while read -r ...
    do
        ...
    done < <(command)

    # POSIX (1)
    # Same, but with
    # temporary file
    command > file
    while read -r ...
    do
        ...
    done < file
    rm file

    # POSIX (2)
    # while is being run in
    # separate environment
    # due to pipe(|)
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
  sizes. The idea of splitting a file into
  chunks of lines and running the search in
  parallel is intriguing, but the overhead of
  starting perl with `parallel` is orders of
  magnitude more expensive compared to running
  already optimized `grep` only once.
  Otherwise, GNU `parallel` is
  excellent for making full use of multiple
  cores. Based on StackOverflow discussions,
  if file sizes are in the tens of megabytes,
  GNU
  [`parallel`](https://www.gnu.org/software/parallel/)
  can help speed things up.
  See [code](./bin/t-command-grep-parallel.sh).

```
    parallel --pipepart --arg-file "$largefile" grep "$re"
```

# ABOUT POSIX, SHELLS AND PORTABILITY

## About Legacy Bourne Shell scripting practises

In typical cases, the legacy `sh`
([Bourne Shell](https://en.wikipedia.org/wiki/Bourne_shell))
is not a relevant target for shell scripting.
These practices are best left to
archaeologists and historians to study;
time has long eroded their relevance. All
Linux and and relevant UNIX operating systems
have long provided an
`sh` that is POSIX-compliant enough. Note that
nowadays `sh` is
usually a symbolic link to
[dash](https://tracker.debian.org/pkg/dash)
(on Linux),
[ksh](https://tracker.debian.org/pkg/ksh93u+m)
(on others), or it may point to
[Bash](https://www.gnu.org/software/bash)
(on macOS).

Examples or archaic coding practises:

```
    if [ x"$a" = "y" ]; then ...

    # Variable lenght is non-zero
    if [ -n "$a" ] ...

    # Variable lenght is zero
    if [ -z "$a" ] ...

    # Deprecated. POSIX will
    # remove logical -o (OR)
    # and -a (AND)
    if [ "$a" = "y" -o "$b" = "y" ] ...

```
Modern equivalents:
```

    # Equality
    if [ "$a" = "y" ] ..

    # Variable has something
    if [ "$a" ] ...

    # Variable is empty
    if [ ! "$a" ] ...

    if [ "$a" = "y" ] || [ "$b" = "y" ]; then ...

```


## Requirements and shell scripts

Writing shell scripts inherently involves considering several factors.

- *Personal scripts.* When writing scripts for
  personal use, choose whichever shell best suits
  your environment. On Linux, the obvious choice
  is Bash. On BSD systems, it would be Ksh. On
  macOS, Zsh is the default and preferred option.

- *Portable scripts.* If you intend to use the
  scripts across some operating systems — from
  Linux to Windows
  ([Git Bash](https://gitforwindows.org/),
  [Cygwin](https://cygwin.com),
  [MSYS2](https://www.msys2.org) [\*][\*\*]) —
  the obvious choice would be Bash. Between macOS and
  Linux, writing scripts in Bash is generally
  more portable than writing them in
  Zsh because Linux doesn't have Zsh installed
  by default. With macOS however, the choice
  of Bash is a bit more involved (see next).

- *POSIX-compliant scripts*. If you intend to
  use the scripts across a variety of operating
  systems — from Linux, BSD, and macOS to various
  Windows Linux-like environments — the issues
  become quite complex.
  You are probably better off writing `sh`
  POSIX-compliant scripts and testing them with
  [dash](https://tracker.debian.org/pkg/dash),
  since relying on Bash can lead to
  unexpected issues — different systems have
  different Bash versions, and there’s no
  guarantee that a script written on Linux will
  run without problems on older Bash versions,
  such as the outdated 3.2 version in `/bin/bash`
  on macOS. Requiring users to install a newer
  version on macOS is not trivial because
  `/bin/bash` is not replaceable.

[\*] "Git Bash" is available with the popular
native Windows installation of Git. Under the
hood, it is based on MSYS, which in turn is
based on Cygwin... so the common denominator of
all native Windows Linux-like environments is the
Cygwin base. In all practical terms, it
provides the same Linux-like command-line
utilities, including Bash. For curious readers,
Windows
[MobaXterm](https://mobaxterm.mobatek.net/),
a Swiss-army knife for terminals and connectivity,
includes a Cygwin-based Bash shell with its own `apt`-style
Debian-like package manager to install additional
Linux software.

[\*\*] In Windows, there is also the Windows
Subsystem for Linux
([WSL](https://learn.microsoft.com/en-us/windows/wsl/)),
where you can install Linux distributions like
Debian and Ubuntu. Bash is the obvious choice
for shell scripts in this environment.

## Writing POSIX compliant shell scrips

**Shells and POSIX compliant scripts**

For all practical purposes, there is no need to
overthink or attempt to write *pure* POSIX shell
scripts. Let's consider shells in order
of their strictness to POSIX:


- [posh](https://tracker.debian.org/pkg/posh).
  Minimal `sh`, Policy-compliant Ordinary SHell.
  Very close to POSIX. Stricter than
  `dash`. Supports for defining
  `local` variables in functions. The
  keyword is not defined in POSIX.
- [dash](https://tracker.debian.org/pkg/dash).
  Minimal `sh`, Debian Almquish Shell.
  Close to POSIX. Supports for example
  `local` keyword.
  The shell aims to meet the
  requirements of Debian Linux distribution.
- [Busybox ash](https://www.busybox.net) is based
  on `dash` but some more features added.
  See ServerFault
  ["What's the Busybox default shell?"](https://serverfault.com/questions/241959/whats-the-busybox-default-shell)

Let's also consider `/bin/sh` in
different Operating Systems. For more about the history of the `sh` shell,
see the well-rounded discussion on StackExchange.
 [What does it mean to be "sh compatible"?](https://unix.stackexchange.com/q/145522)

<!-- <contactme2016@tangentsoft.com> -->
[Picture](https://tangentsoft.com/misc/unix-shells.svg)
"Bourne Family Shells" by
[tangentsoft.com](tangentsoft.com)
<picture>
    <source srcset="https://tangentsoft.com/misc/unix-shells-large.png">
    <img src="pic/unix-shells.svg" alt="Bourne Family Shells" style="width:auto;">
</picture>

- On Linux, most distributions already use, or
  are moving towards using, `sh` as a symlink to
  [dash](https://tracker.debian.org/pkg/dash).
- On the most conservative NetBSD, it is `ash`,
  the old Almquist shell.
  On FreeBSD, `sh` is based on `dash`.
  On
  [OpenBSD, sh](https://man.netbsd.org/sh.1) is
  [ksh93](https://tracker.debian.org/pkg/ksh93u+m)
  from the
  [Ksh family](https://en.wikipedia.org/wiki/KornShell).
- On many commercial, conservative UNIX systems
  `sh` is nowadays quite capable
  [ksh93](https://tracker.debian.org/pkg/ksh93u+m).
- On macOS, `sh` points to `bash --posix`, where
  the Bash version is indefinitely stuck at
  version 3.2.x due to Apple avoiding the GPL-3
  license in later Bash versions. If you write
  `/bin/sh` scripts in macOS, it is best to check
  them explicitly for portability with:
```
    # Check /bin/sh compliance
    dash -nx script.sh
```

In practical terms, if you plan to aim
for POSIX-compliant shell scripts, the best
shells for testing are `posh` and `dash`. You can
also extend testing with BSD Ksh shells and
other shells. See
[FURTHER READING](#further-reading) for external
utilities to check and improve shell
scripts even more.

    # Save in shell startup file
    # like ~/.bashrc

    shelltest()
    {
        for script in "$@"
        do
            for shell in \
                posh \
                dash \
                "busybox ash" \
                mksh \
                ksh \
                bash
            do
                echo "-- shell: $shell"
                $shell -nx "$script"
            done
        done

        unset shell script
    }

    # Use is like:
    shelltest script.sh

    # External utility to check code
    shellcheck script.sh

    # External utility to check code
    checkbashisms script.sh

**Shebang line in shell scripts**

Note that POSIX does not defined the
[shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)).
See
[exec family of functions' RATIONALE](https://pubs.opengroup.org/onlinepubs/9699919799/functions/exec.html#tag_16_111_08)

> (...) Another way that some historical
> implementations handle shell scripts is by
> recognizing the first two bytes of the file as
> the character string "#!" and using the
> remainder of the first line of the file as the
> name of the command interpreter to execute.

The first bytes of a script typically contain
two special ASCII codes, a special comment if
you wish, which is read by the kernel. Note
that this is a de facto convention, universally
supported even though it is not defined by
POSIX.

    #! /bin/sh
    #
    # 1. Space is allowed after "#!"
    #    for readability.
    #
    # 2. The <interpreter> must be full
    #     path name. Not like:
    #
    #    #! sh
    #
    # 3. ONE option word can be added
    #    after the <interpreter>. Any
    #    more than that is not portable
    #    accross other than Linux
    #    Kernels.
    #
    #    #! /bin/sh -eu
    #    #! /bin/bash -eu
    #    #! /usr/bin/awk -f

Note that on macOS, `/bin/bash` is hard-coded
to Bash version 3.2.57 where in 2025 lastest Bash is
[5.2](https://tracker.debian.org/pkg/bash).
You cannot uninstall
it, even with root access, without disabling
System Integrity Protection. If you install a
newer Bash version with `brew install bash`, it
will be located in `/usr/local/bin/bash`. Due
to this limitation, for Bash, the shebang line
— from a portability point of view — is best
written in the following format:

    #! /usr/bin/env bash

**Portability of utilities**

The utilities that you use in scripts, those of
`echo`, `cut`, `tail` make big part of of the
scripts. If you want to ensure portability,
check options defined in
[POSIX 2018](https://pubs.opengroup.org/onlinepubs/9699919799/).
See top left menu "Shell & Utilities"
followed by bottom left menu
["4. Utilities"](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html)

Notable observations:

- [`echo`](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/echo.html).
  Use
  [`printf`](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/printf.html)
  when more is needed.

```
  # Not POSIX
  echo -e "line\nline"
  echo -n "without newline"
```

- [`read`](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/read.html).
  No `-N` option to read
  file into memory for fast
  in-memory pattern matching
  later.

```
   # Not POSIX
   # Read max 100 KiB to $REPLY
   read -N$((100 * 1024)) < file

   case $REPLY in
        *pattern*)
            # match
            ;;
   esac
```

- [`command -v`](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/command.html).
  To check if a command exists, use `command -v
  <command>` and not `which <command>`. "which"
  is not part of POSIX and is not a portable
  solution. Note that POSIX also defines
  [`type`](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/type.html),
  as in `type <command>`, but in practice, the
  semantics, return codes, and output are not as
  uniform compared to `command -v`. POSIX also
  has
  [`hash`](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/type.html),
  as in `hash <command>`, but it is less
  consistently supported across shells. Neither
  `type` nor `hash` is supported by `posh`.

```
    REQUIRE="sqlite curl"

    RequireFeatures ()
    {
        for cmd in $REQUIRE
        do
            if ! command -v "$cmd" > /dev/null; then
                echo "ERROR: missing required command: $cmd" >&2
                exit 1
            fi
        done

        unset cmd
    }

    # Before program starts
    RequireFeatures
    ...
```

**Case Study: sed**

It's not just about
choosing to write in `sh` shell; the utilities called from
the script also pose problems. For example, the
Linux GNU `sed(1)` and its options differ or
are incompatible. The Linux GNU
[`sed`](https://www.gnu.org/software/sed/)
`--in-place` option for replacing file content
cannot be used in macOS and BSD. Additionally,
in macOS and BSD, you will find GNU programs
under a `g`-prefix, such as `gsed(1)`, etc.
See StackOverflow discussion
["sed command with -i option failing on Mac, but works on Linux"](https://stackoverflow.com/q/4247068). For more
discussions about the topic, see
[1](https://stackoverflow.com/q/48712373),
[2](https://stackoverflow.com/q/16745988),
[3](https://stackoverflow.com/q/7573368).

    # Linux
    #
    # GNU sed(1). Replace 'this' with
    # 'that'

    sed -i 's/this/that/g' file

    # macOS
    #
    # This does not work. The '-i'
    # option has different syntax and
    # semantics. There is no workaround
    # to make the '-i' option work
    # across all operating systems.

    sed -i 's/this/that/g' file

    # Portable
    #
    # The most portable is to use
    # Perl which is almost always
    # available although it
    # is not part of the POSIX
    # utilities. Let's disregard
    # special cases like busybox
    # etc.

    perl -i -pe 's/this/that/g' file

# RANDOM NOTES

See the Bash manual how to use
[`time`](https://www.gnu.org/software/bash/manual/bash.html#Pipeline)
reserved word with
[TIMEFORMAT](https://www.gnu.org/software/bash/manual/bash.html#index-TIMEFORMAT)
variable to display results in different
formats. The use of time as a reserved word
permits the timing of shell builtins, shell
functions, and pipelines.

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
- Use
  [POSIX](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_03)
  `$(cmd)`
  command substituion instead of
  archaic backtics as in \`cmd\`. For more
  information, see
  https://mywiki.wooledge.org/BashFAQ/082
  **Note**: For the past 20 years, all
  modern `sh` shells have supported the readable
  `$()` substitution syntax. This includes, for
  example, UNIX operating systems like HP-UX and
  Oracle Solaris 10 from 2005. Oracle Solaris 10
  support ends in
[2026](https://www.theregister.com/2024/01/29/oracle_extends_solaris_support/#:~:text=During%202023%2C%20Oracle%20added%20another,2027%20instead%20of%20during%202024)
  (see
  [version history](https://www.liquisearch.com/solaris_operating_system/version_history)).
- Use `shellcheck` (Haskell) to
  to help to
  improve and write portable POSIX scripts.
  It can statically Lint scripts for potential
  mistakes. There is also a web interface where
  you can upload the script at
  https://www.shellcheck.net. In Debian,
  see package "shellcheck". See manual page at
  https://manpages.debian.org/testing/shellcheck/shellcheck.1.en.html
- Use `checkbashisms` command to help to
  improve and write portable POSIX scripts.
  In Debian, the command is available
  in package "devscripts". See
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
optimize, performance, profiling, portability
