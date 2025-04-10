<!--
INFORMATION FOR EDITÍNG

- Github Markdown Guide:
  https://is.gd/nqSonp

- VSCode:
  Palette: C-p
  Open preview markdown C-S-v

- URL text fragments: #:~:text=
  https://developer.mozilla.org/en-US/docs/Web/URI/Reference/Fragment/Text_fragments

- About accessibility

  To support viewing and editing GitHub
  pages on phone displays, the maximum
  column widths are described below.
  Exception: The GNU License at the end
  of file is included verbatim.

  col type
  ---------------------------------
  35  Code: bullet: ``` ... ``´)
  41  Regular text and paragaphs.
      Github line limit to support
      editing.
  ---------------------------------------

  In Emacs:
  <go to the end of above "-">
  C-u C-x f (M-x set-fill-column)
  M-x display-fill-column-indicator-mode

MISCELLANEOUS

- To search POSIX.1-2024 in Google
  site:pubs.opengroup.org inurl:9799919799 <search>

-->

# 1.0 SHELL SCRIPT PERFORMANCE AND PORTABILITY

How can you make shell scripts portable
and run faster? That are the questions
these test cases aim to answer.

Table of Contents

- [1.0 SHELL SCRIPT PERFORMANCE AND PORTABILITY](#10-shell-script-performance-and-portability)
  - [1.1 THE PROJECT STRUCTURE](#11-the-project-structure)
  - [1.2 THE PROJECT DETAILS](#12-the-project-details)
- [3.0 ABOUT PERFORMANCE](#30-about-performance)
  - [3.1 GENERAL PERFORMANCE ADVICE](#31-general-performance-advice)
  - [3.2 SHELLS AND PERFORMANCE](#32-shells-and-performance).
  - [3.3 MAJOR PERFORMANCE GAINS](#33-major-performance-gains)
  - [3.4 MODERATE PERFORMANCE GAINS](#34-moderate-performance-gains)
  - [3.5 MINOR PERFORMANCE GAINS](#35-minor-performance-gains)
  - [3.6 NO PERFORMANCE GAINS](#36-no-performance-gains)
- [4.0 PORTABILITY](#40-portability)
  - [4.1 LEGACY SHELL SCRIPTING](#41-legacy-shell-scripting)
  - [4.2 REQUIREMENTS AND SHELL SCRIPTS](#42-requirements-and-shell-scripts)
  - [4.3 WRITING POSIX COMPLIANT SHELL SCRIPS](#43-writing-posix-compliant-shell-scrips)
  - [4.4 SHEBANG LINE IN SCRIPTS](#44-shebang-line-in-scripts)
    - [4.4.1 About Bash and Shebang](#441-about-bash-and-shebang)
    - [4.4.2 About Python and Shebang](#442-about-python-and-shebang)
  - [4.5 PORTABILITY OF UTILITIES](#45-portability-of-utilities)
    - [4.5.1 Case Study: sed](#451-case-study-sed)
    - [4.5.2 Case Study: awk](#451-case-study-awk)
  - [4.6 MISCELLANEUS NOTES](#46-miscellaneus-notes)
- [5.0 RANDOM NOTES](#50-random-notes)
- [6.0 FURTHER READING](#60-further-reading)
  - [6.1 BASH PROGRMAMING](#61-bash-progrmaming)
  - [6.2 PORTABILITY AND UTILITIES](#62-portability-and-utilities)
  - [6.3 STANDARDS](#63-standards)
  - [6.4 MISCELLANEOUS LINKS](#64-miscellaneous-links)
- [COPYRIGHT](#copyright)
- [LICENSE](#license)

The tests reflect results under Linux
using GNU utilities. The focus is on the
features found in
[Bash](https://www.gnu.org/software/bash)
and
[POSIX.1-2024](https://pubs.opengroup.org/onlinepubs/9799919799/)
compliant `sh` shells. The term compliant
is used here as "most POSIX compliant",
as there is no, and has never been,
shell that is fully POSIX compliant.
POSIX is useful if you are looking for
more portable scripts. See also POSIX in
[Wikipedia](https://en.wikipedia.org/wiki/POSIX).

> Please note that `sh` here refers to
> modern, best-of-effort POSIX-compatible,
> minimal shells like
> [dash](https://tracker.debian.org/pkg/dash)
> and
> [posh](https://tracker.debian.org/pkg/posh).
> See section [PORTABILITY, SHELLS AND POSIX](#posix-shells-and-portability).

In Linux like systems, for all rounded
shell scripting, Bash is the sensible
choice for data manipulation in memory
with
[arrays](https://www.gnu.org/software/bash/manual/html_node/Arrays.html),
associative arrays, and strings with an
extended set of parameter expansions,
regular expressions, including extracting
regex matches and utilizing functions.

In other operating systems, for example
BSD, the obvious choice for shell
scripting would be fast
[Ksh](https://en.wikipedia.org/wiki/KornShell)
([ksh93](https://tracker.debian.org/pkg/ksh93u+m),
[mksh](https://tracker.debian.org/pkg/mksh),
etc.).

Shell scripting is about combining
redirections, pipes, calling external
utilities, and gluing them all together.
Shell scripts are also quite portable by
default, requiring no additional
installation.
[Perl](https://www.perl.org)
or
[Python](https://www.python.org)
excel in their respective fields, where
the requirements differ from those of the
shell.

Certain features in Bash are slow, but
knowing the cold spots and using
alternatives helps. On the other hand,
small POSIX `sh`, for example
[dash](https://tracker.debian.org/pkg/dash),
scrips are much faster at calling
external processes and functions. More
about this in section
[SHELLS AND PERFORMANCE](#32-shells-and-performance).

The results presented in this README
provide only some highlighs from the test
cases listed in RESULTS. Consider the raw
[`time`](https://www.gnu.org/software/bash/manual/bash.html#Reserved-Words)
results only as guidance, as they reflect
only the system used at the time of
testing. Instead, compare the relative
order in which each test case produced
the fastest results.

## 1.1 THE PROJECT STRUCTURE

- [RESULTS](./doc/RESULTS.md)
- [RESULTS-BRIEF](./doc/RESULTS-BRIEF.txt)
- [RESULTS-PORTABILITY](./doc/RESULTS-PORTABILITY.txt)
- The test cases and code in [bin/](./bin/)
- [USAGE](./USAGE.md)
- [CONTRIBUTING](./CONTRIBUTING.md)

```
    bin/            The tests
    doc/            Results by "make doc"
    COPYING         License (GNU GPL)
    INSTALL         Install instructions
    USAGE.md        How to run the tests
    CONTRIBUTING.md Writing test cases
```

## 1.2 THE PROJECT DETAILS

- Homepage:
  https://github.com/jaalto/project--shell-script-performance-and-portability

- To report bugs:
  see homepage.

- Source repository:
  see homepage.

- **Depends**:
  Bash, GNU coreutils, file
  `/usr/share/dict/words`
  (Debian package: wamerican).

- **Optional depends**:
  GNU make.
  For some tests: GNU parallel.

# 3.0 ABOUT PERFORMANCE

## 3.1 GENERAL PERFORMANCE ADVICE

Regardless of the shell you use for
scripting
([sh](https://tracker.debian.org/pkg/dash),
[ksh](https://tracker.debian.org/pkg/ksh93u+m),
[bash](https://www.gnu.org/software/bash)),
consider these factors.


- If you run scripts on many small files,
  set up a RAM disk and copy the files to
  it. This can lead to massive speed
  gains. In Linux, see
  [tmpfs](https://en.wikipedia.org/wiki/Tmpfs),
  which allows you to set a size limit,
  unlike the memory-hogging
  [ramfs](https://wiki.debian.org/ramfs),
  which can fill all available memory and
  potentially halt your server.

- If you know the files beforehand,
  preload them into memory. This can also
  lead to massive speed gains.
  In Linux, see
  [vmtouch](https://hoytech.com/vmtouch/).

- If you have tasks that can be run concurrently,
  use
  [Perl](https://www.perl.org)
  based
  [GNU parallel](https://www.gnu.org/software/parallel/)
  for massive gains in performance.
  See also how to use
  [semaphores](https://www.gnu.org/software/parallel/sem.html#understanding-a-semaphore)
  ([tutorial](https://www.gnu.org/software/parallel/parallel_examples.html#example-working-as-mutex-and-counting-semaphore))
  to wait for all concurrent tasks to
  finish before continuing with the rest
  of the tasks in the pipeline. In some
  cases, even parallelizing work with GNU
[`xargs --max-procs=0`](https://www.gnu.org/software/findutils/manual/html_node/find_html/xargs-options.html)
can help.

- Use GNU utilities. According to
  benchmarks, like
  [StackOverflow](https://stackoverflow.com/a/22661643),
  the GNU `grep` is considerably faster
  and more optimized than the operating
  system's default. For shells, the GNU
  utilities consist mainly of
  [coreutils](https://tracker.debian.org/pkg/coreutils),
  [grep](https://tracker.debian.org/pkg/grep) and
  [awk](https://tracker.debian.org/pkg/gawk).
  If needed, arrange `PATH` to prefer
  GNU utilities (for example, on
  macOS).

- Minimize extra processes as much as
  possible. In most cases, a single
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
  *Note*: If you need to process large
  files, use a lot of regular
  expressions, manipulate or work on
  data extensively, there is probably
  nothing that can replace the speed of
  [Perl](https://www.perl.org)
  unless you go even lower-level
  languages like `C`. But then again,
  we assume that you know how to choose
  your tools in those cases.

```bash
    cmd | awk '{...}'

    # ... could probably
    # replace all of these

    cmd | head ... | cut ...
    cmd | grep ... | sed ...
    cmd | grep ... | grep -v ... | cut ...
```

- *Note*: if you have hordes of RAM,
  no shortage of cores, and large
  files, then utilize pipelines `<cmd>
  | ...` as much as possible because
  the Linux Kernel will optimize things
  in memory better. In more powerful
  systems, many latency and performance
  issues are not as relevant.

- Use Shell built-ins
  (see [Bash](https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html))
  and not binaries:

```bash
    echo     # not /usr/bin/echo
    printf   # not /usr/bin/printf
    [ ... ]  # not /usr/bin/test
```

## 3.2 SHELLS AND PERFORMANCE

TODO

## 3.3 MAJOR PERFORMANCE GAINS

- In Bash, It is at least 60 times faster
  to perform regular expression string
  matching using the binary operator
  [`=~`](https://www.gnu.org/software/bash/manual/bash.html#index-_005b_005b)
  rather than to calling external
  POSIX utilities
  [`expr`](https://pubs.opengroup.org/onlinepubs/9799919799/utilities/expr.html)
  or
  [`grep`](https://pubs.opengroup.org/onlinepubs/9799919799/utilities/grep.html).

  **NOTE**: In POSIX `sh`, like
  [dash](https://tracker.debian.org/pkg/dash)
  , calling utilities is
  *extremely* fast. Compared to Bash's
  [`[[]]`](https://www.gnu.org/software/bash/manual/bash.html#index-_005b_005b),
  the `expr` in `dash` is only 5x
  slower, which is negligible because
  the time differences are measured in
  mere few milliseconds.
  See [code](./bin/t-string-match-regexp.sh)

```bash
    str="abcdef"
    re="b.*e"

    # Bash, Ksh
    [[ $str =~ $re ]]

    # In Bash, at least 60x slower
    expr match "$str" ".*$re"

    # In Bash, at least 100x slower
    echo "$str" | grep -E "$re"

    # --------------------------------
    # Different shells compared.
    # --------------------------------

    ./run.sh --shell dash,ksh93,bash t-string-match-regexp.sh

    Run shell: dash
    # t1     <skip>
    # t2     real 0.010s  expr
    # t3     real 0.010s  grep
    Run shell: ksh93
    # t1     real 0.001s [[ =~ ]]
    # t2     real 0.139s expr
    # t3     real 0.262s grep
    Run shell: bash
    # t1     real 0.003s [[ =~ ]]
    # t2     real 0.200s expr
    # t3     real 0.348s grep
```

- In Bash, it is about 50 times
  faster to do string manipulation in
  memory, than calling external
  utilities. Seeing the measurements
  just how expensive it is, reminds us
  to utilize the possibilities of POSIX
  `#`, `##`, `%` and `%%`
  [parameter expansions](https://pubs.opengroup.org/onlinepubs/009604499/utilities/xcu_chap02.html#tag_02_06_02).
  See more in
  [Bash](https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameter-Expansion).
  See [code](./bin/t-string-file-path-components.sh).

```bash
    str="/tmp/filename.txt.gz"

    # (1) Almost instantaneous
    # Delete up till first "."

    ext=${str#*.}

    # (2) In Bash, over 50x slower
    #
    # NOTE: identical in speed
    # and execution to:
    # cut -d "." -f 2,3 <<< "$str"

    ext=$(echo "$str" | cut -d "." -f 2,3)

    # (3) In Bash, over 70x slower

    ext=$(echo "$str" | sed 's/^[^.]\+//')

    # --------------------------------
    # Different shells compared.
    # --------------------------------

    ./run.sh --shell dash,ksh93,bash t-string-file-path-components.sh

    Run shell: dash
    # t3aExt real 0.009s (1)
    # t3cExt real 0.008s (2)
    # t3eExt real 0.009s (3)
    Run shell: ksh93
    # t3aExt real 0.001s
    # t3cExt real 0.193s
    # t3eExt real 0.288s
    Run shell: bash
    # t3aExt real 0.004s
    # t3cExt real 0.358s
    # t3eExt real 0.431s

```

- In Bash, it is about 10 times faster
  to read a file into memory as a
  string and use
  [pattern matching](https://www.gnu.org/software/bash/manual/bash.html#Pattern-Matching)
  or regular expressions binary
  operator
  [`=~`](https://www.gnu.org/software/bash/manual/bash.html#index-_005b_005b)
  on string. In-memory handling is much
  more efficient than calling the
  `grep` command in Bash on a file,
  especially if multiple matches are
  needed.
  See [code](./bin/t-file-grep-vs-match-in-memory.sh).

```bash
    # Bash, Ksh
    str=$(< file)

    if [[ $str =~ $regexp1 ]]; then
        ...
    elif [[ $str =~ $regexp2 ]]; then
        ...
    fi

    # --------------------------------
    # Different shells compared.
    # --------------------------------

    (1) read once + case..end
    (2) loop do.. grep file ..done
    (3) loop do.. case..end ..done

    ./run.sh --shell dash,ksh93,bash t-file-grep-vs-match-in-memory.sh

    Run shell: dash
    # t1b    real 0.023s (1) once
    # t2     real 0.018s (2) grep
    # t3     real 0.021s (3) case
    Run shell: ksh93
    # t1b    real 0.333s (1) once
    # t2     real 0.208s (2) grep
    # t3     real 0.453s (3) case
    Run shell: bash
    # t1b    real 0.048s (1) once
    # t2     real 0.277s (2) grep
    # t3     real 0.415s (3) case
```

- In Bash, it is about 8 times faster,
  to use
  [nameref](https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameters)
  to return a value. In Bash, the
  `ret=$(fn)` is inefficient to call
  functions. On the other hand, in
  POSIX `sh` shells, like
  [dash](https://tracker.debian.org/pkg/dash),
  there
  is practically no overhead in using
  `$(fn)`.
  See [code](./bin/t-function-return-value-nameref.sh).

```bash
    # An exmaple only. Not needed in
    # POSIX sh shells as ret=$(fn)
    # is already fast.

    fnNamerefPosix()
    {
        # NOTE: uses non-POSIX
        # 'local' but it is widely
        # supported in POSIX-compliant
        # shells: dash, posh, mksh,
        # ksh93 etc.

        local retref=$1
        shift
        local arg=$1

        eval "$retref=\$arg"
    }

    fnNamerefBash()
    {
        local -n retref=$1
        shift
        local arg=$1

        retref=$arg
    }

    # Return value returned to
    # variable 'ret'

    fnNamerefPosix ret "arg"
    fnNamerefBash ret "arg"

    # --------------------------------
    # Different shells compared.
    # --------------------------------

    ./run.sh --shell dash,ksh93,bash t-function-return-value-nameref.sh

    Run shell: dash
    # t1     <skip>
    # t2     real 0.006s fnNamerefPosix
    # t3     real 0.005s ret=$(fn)

    Run shell: ksh93
    # t1     <skip>
    # t2     real 0.004s fnNamerefPosix
    # t3     real 0.005s ret=$(fn)

    Run shell: bash
    # t1     real 0.006s fnNamerefBash
    # t2     real 0.006s fnNamerefPosix
    # t3     real 0.094s ret=$(fn)
```


- In Bash, it is about 2 times faster
  for line-by-line handling to read
  the file into an array and then loop
  through the array. The built-in
  [`readarray`](https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html#index-readarray)
  is synonym for
  [`mapfile`](https://www.gnu.org/software/bash/manual/bash.html#index-mapfile),
  See [code](./bin/t-file-read-content-loop.sh).

```bash
    # Bash
    readarray < file

    for line in "${MAPFILE[@]}"
    do
        ...
    done

    # POSIX. In bash, slower
    while read -r line
    do
        ...
    done < file

    # --------------------------------
    # Different shells compared.
    # --------------------------------

    ./run.sh --shell dash,ksh93,bash t-file-read-content-loop.sh

    Run shell: dash
    # t1     <skip>
    # t2     real 0.085  POSIX
    Run shell: ksh93
    # t1     <skip>
    # t2     real 0.021  POSIX
    Run shell: bash
    # t1     real 0.045  readarray
    # t2     real 0.108  POSIX

```

- In Bash, it is about 2 times faster to
  prefilter with
  [grep](https://tracker.debian.org/pkg/grep)
  to process only
  certain lines instead of reading the
  whole file into a loop and then
  selecting lines. The
  [process substitution](https://www.gnu.org/software/bash/manual/html_node/Process-Substitution.html)
  is more general because variables
  persist after the loop. The
  [dash](https://tracker.debian.org/pkg/dash)
  is very fast compared to Bash.
  See [code](./bin/t-file-read-match-lines-loop-vs-grep.sh).

```bash
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
    # NOTE: extra calls
    # required for tmpfile
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

    # --------------------------------
    # Different shells compared.
    # --------------------------------

    ./run.sh --shell dash,ksh93,bash t-file-read-match-lines-loop-vs-grep.sh

    Run shell: dash
    # t1a    real 0.015s grep prefilter
    # t2a    real 0.012s loop: case...esac
    Run shell: ksh93
    # t1a    real 2.940s
    # t2a    real 1.504s
    Run shell: bash
    # t1a    real 4.567s
    # t2a    real 10.88s

```

## 3.4 MODERATE PERFORMANCE GAINS

- It is about 10 times faster to split
  a string into an array using list
  rather than using Bash here-string.
  This is because
[HERE STRING](https://www.gnu.org/software/bash/manual/bash.html#Here-Strings)
  `<<<` uses a pipe or temporary file,
  whereas Bash list operates entirely
  in memory. The pipe buffer behavor
  was introduced in
  [Bash 5.1 section c](https://github.com/bminor/bash/blob/master/CHANGES).
  *Warning*: Please note that using the
  `(list)` statement will undergo
  pathname expansion so globbing
  characters like `*`, `?`, etc. in
  string would be a problem. The
  pathname expansion can be disabled.
  See [code](./bin/t-variable-array-split-string.sh).

```bash
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
        set -o noglob

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

- It is about 2 times faster to read
  file into a string using Bash command
  substitution
  [`$(< file)`](https://www.gnu.org/software/bash/manual/bash.html#Command-Substitution).
  **NOTE**: In POSIX `sh`, like
  `dash`, the `$(cat file)` is
  extremely fast.
  See [code](./bin/t-file-read-into-string.sh).

```bash
    # Bash
    str=$(< file)

    # In Bash: 1.8x slower
    # Read max 100 KiB
    read -r -N $((100 * 1024)) str < file

    # In Bash: POSIX, 2.3x slower
    str=$(cat file)

    # --------------------------------
    # Different shells compared.
    # --------------------------------

    ./run.sh --shell dash,ksh93,bash t-file-read-into-string.sh

    Run shell: dash
    # t1     <skip>
    # t2     <skip>
    # t3     real 0.013s $(cat ...)
    Run shell: ksh93
    # t1     real 0.088s $(< ...)
    # t2     real 0.095s read -N
    # t3     real 0.267s $(cat ...)
    Run shell: bash
    # t1     real 0.139s $(< ...)
    # t2     real 0.254s read -N
    # t3     real 0.312s $(cat ...)
```

## 3.5 MINOR PERFORMANCE GAINS

According to the results, none of
these offer practical benefits.

- The Bash
  [brace expansion](https://www.gnu.org/software/bash/manual/bash.html#Brace-Expansion)
  `{N..M}` might offer a
  neglible advantage. However it may be
  impractical because `N..M` cannot be
  parameterized. Surprisingly, the
  simple and elegant `$(seq N M)` is
  fast, even though
[command substitution](https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html#Command-Substitution)
  uses a subshell. The last POSIX
  `while` loop example was slightly
  slower in all subsequent tests.
  See [code](./bin/t-statement-arithmetic-for-loop.sh).

```bash

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

- One might think that choosing
  optimized `grep` options would make a
  difference. In practice, for typical
  file sizes (below few Megabytes),
  performance is nearly identical even
  with the ignore case option included.
  Nonetheless, there may be cases where
  selecting `LANG=C`, using
  `--fixed-strings`, and avoiding
  `--ignore-case` might improve
  performance, at least according to
  StackOverflow discussions with large
  files.
  See [code](./bin/t-command-grep.sh).

```bash
    # The same performance. Regexp
    # engine does not seem to be
    # the bottleneck

    LANG=C grep --fixed-strings ...
    LANG=C grep --extended-regexp ...
    LANG=C grep --perl-regexp ...
    LANG=C grep --ignore-case ...
```

## 3.6 NO PERFORMANCE GAINS

None of these offer any advantages to speed up shell scripts.

- The Bash-specific expression
  [`[[]]`](https://www.gnu.org/software/bash/manual/bash.html#index-_005b_005b)
  might offer a minuscule advantage but
  only in loops of 10,000 iterations.
  Unless the safeguards provided by
  Bash `[[ ]]` are important, the POSIX
  tests will do fine.
  See [code](./bin/t-statement-if-test-posix-vs-bash.sh).

```bash
    [ "$var" = "1" ] # POSIX
    [[ $var = 1 ]]   # Bash

    [ ! "$var" ]     # POSIX
    [[ ! $var ]]     # Bash
    [ -z "$var" ]    # archaic
```

- There are no practical differences
  between these. The POSIX
  [arithmetic expansion](https://www.gnu.org/software/bash/manual/bash.html#Arithmetic-Expansion)
  `$(())`
  compound command will do fine. Note
  that the null command
  [`:`](https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html)
  utilizes the command's side effect to
  "do nothing, but evaluate elements"
  and therefore may not be the most
  readable option.
  See [code](./bin/t-statement-arithmetic-increment.sh).

```bash
    i=$((i + 1))     # POSIX, preferred
    : $((i++))       # POSIX, Uhm
    : $((i = i + 1)) # POSIX, Uhm
    ((i++))          # Bash, Ksh
    let i++          # Bash, Ksh
```

- There is no performance
  difference between a
  Bash-specific expression
  [`[[]]`](https://www.gnu.org/software/bash/manual/bash.html#index-_005b_005b)
  for pattern matching compared to
  POSIX `case..esac`. Interestingly
  pattern matching is 4x slower under
  [dash](https://tracker.debian.org/pkg/dash)
  compared to Bash. However,
  that means nothing because the time
  differences are measured in minuscule
  milliseconds (0.002s).
  See [code](./bin/t-string-match-pattern.sh).

```bash
    string="abcdef"
    pattern="*cd*"

    # Bash
    if [[ $string == $pattern ]]; then
	    ...
    fi

    # POSIX
    case $string in
        $pattern)
            :    # Same as true
            ;;
        *)
            false
            ;;
    esac

    # --------------------------------
    # Different shells compared.
    # --------------------------------

    ./run.sh --shell dash,ksh93,bash t-string-match-regexp.sh

	Run shell: dash
	# t1     <skip>
	# t2      real 0.011 POSIX
	Run shell: ksh93
	# t1     real 0.004  [[ == ]]
	# t2     real 0.002  POSIX
	Run shell: bash
	# t1     real 0.003  [[ == ]]
	# t2     real 0.002  POSIX
```

- There is no performance difference
  between a regular while loop and a
  [process substitution](https://www.gnu.org/software/bash/manual/html_node/Process-Substitution.html)
  loop. However, the latter is more
  general, as any variable set during
  the loop will persist after *and*
  there is no need to clean up
  temporary files like in POSIX (1)
  solution. The POSIX (1) loop is
  marginally faster but the speed gain
  is lost by the extra `rm` command.
  See [code](./bin/t-command-output-vs-process-substitution.sh).

```bash
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
  a `perl` program, makes things
  notably slower for typical file
  sizes. The idea of splitting a file
  into chunks of lines and running the
  search in parallel is intriguing, but
  the overhead of starting Perl
  interpreter with
  `parallel` is orders of magnitude
  more expensive compared to running
  already optimized `grep` only once.
  Usually the limiting factor when
  grepping a file is the disk's I/O
  speed. Otherwise, GNU `parallel` is
  excellent for making full use of
  multiple cores. Based on
  StackOverflow discussions, if file
  sizes are in the several hundreds of
  megabytes or larger, GNU
  [`parallel`](https://www.gnu.org/software/parallel/)
  can help speed things up.
  See [code](./bin/t-command-grep-parallel.sh).

```bash
    # Possibly add: --block -1
    parallel --pipepart --arg-file "$largefile" grep "$re"
```

# 4.0 PORTABILITY

## 4.1 LEGACY SHELL SCRIPTING

In typical cases, the legacy `sh`
([Bourne Shell](https://en.wikipedia.org/wiki/Bourne_shell))
is not a relevant target for shell
scripting. The Linux and and modern
UNIX operating systems have long
provided an `sh` that is
POSIX-compliant enough. Nowadays `sh`
is usually a symbolic link to
[dash](https://tracker.debian.org/pkg/dash)
(on Linux since 2006),
[ksh](https://tracker.debian.org/pkg/ksh93u+m)
(on some BSDs), or it may point to
[Bash](https://www.gnu.org/software/bash)
(on macOS).

Examples of pre-2000 shell scripting
practises:

```bash
    if [ x$a = y ] ...

    # Variable lenght is non-zero
    if [ -n "$a" ] ...

    # Variable lenght is zero
    if [ -z "$a" ] ...

    # Deprecated in next POSIX
    # version. Operands are
    # not portable.
    # -o (OR)
    # -a (AND)

    if [ "$a" = "y" -o "$b" = "y" ] ...

    # POSIX allows leading
    # opening "(" paren
    case abc in
        (a*) true
             ;;
        (*)  false
             ;;
    esac

```

Modern equivalents:

```bash

    # Equality
    if [ "$a" = "y" ] ..

    # Variable has something
    if [ "$a" ] ...

    # Variable is empty
    if [ ! "$a" ] ...

    if [ "$a" = "y" ] || [ "$b" = "y" ] ...

    # Without leading "(" paren
    case abc in
         a*) :  # "true"
             ;;
         *)  false
             ;;
    esac

```

## 4.2 REQUIREMENTS AND SHELL SCRIPTS

Writing shell scripts inherently
involves considering several factors.

- *Personal scripts.* When writing
  scripts for personal or
  administrative tasks, the choice of
  shell is unimportant. On Linux, the
  obvious choice is Bash. On BSD
  systems, it would be Ksh. On macOS,
  Zsh might be handy.

- *Portable scripts.* If you intend to
  use the scripts across some operating
  systems — from Linux to Windows
  ([Git Bash](https://gitforwindows.org/),
  [Cygwin](https://cygwin.com),
  [MSYS2](https://www.msys2.org) [\*][\*\*]) —
  the obvious choice would be Bash.
  Between macOS and Linux, writing
  scripts in Bash is generally more
  portable than writing them in Zsh
  because Linux doesn't have Zsh
  installed by default. With macOS
  however, the choice of Bash is a bit
  more involved (see next).

- *POSIX-compliant scripts*. If you
  intend to use the scripts across a
  variety of operating systems — from
  Linux, BSD, and macOS to various
  Windows Linux-like environments — the
  issues become quite complex. You are
  probably better off writing `sh`
  POSIX-compliant scripts and testing
  them with
  [dash](https://tracker.debian.org/pkg/dash),
  since relying on Bash can lead to
  unexpected issues — different systems
  have different Bash versions, and
  there’s no guarantee that a script
  written on Linux will run without
  problems on older Bash versions, such
  as the outdated 3.2 version in
  `/bin/bash` on macOS. Requiring users
  to install a newer version on macOS
  is not trivial because `/bin/bash` is
  not replaceable.

[\*] "Git Bash" is available with the
popular native Windows installation of
[Git for Windows](https://git-scm.com/downloads/win).
Under the hood, the installation is based on
MSYS2, which in turn is based on
Cygwin. The common denominator of
all native Windows Linux-like
environments is the
[Cygwin](https://cygwin.com)
base which, in all
practical terms, provides the usual
command-line utilities,
including Bash. For curious readers,
Windows software
[MobaXterm](https://mobaxterm.mobatek.net),
offers X server, terminals
and other connectivity features, but also
somes with Cygwin-based
Bash shell with its own
[Debian-style](https://www.debian.org/doc/manuals/debian-faq/pkgtools.en.html)
`apt` package manager which allows installing
additional Linux utilities.

[\*\*] In Windows, there is also
the Windows Subsystem for Linux
([WSL](https://learn.microsoft.com/en-us/windows/wsl/)),
where you can install (See `wsl --list --onlline`)
Linux distributions like
[Debian](https://en.wikipedia.org/wiki/Debian),
[Ubuntu](https://en.wikipedia.org/wiki/Ubuntu),
[OpenSUSE](https://en.wikipedia.org/wiki/OpenSUSE) and
[Oracle Linux](https://en.wikipedia.org/wiki/Oracle_Linux).
Bash is the obvious choice for shell
scripts in this environment.

## 4.3 WRITING POSIX COMPLIANT SHELL SCRIPS

As this document is more focused on
Linux, macOS, and BSD compatibility,
and less on legacy UNIX operating
systems, for all practical purposes,
there is no need to attempt to write
*pure* POSIX shell scripts. Stricter
measures are required only if you
target legacy UNIX operating systems
whose `sh` may not have changed in 30
years. your best guide probably is
the wealth of knowledge collected by
the GNU autoconf project; see
["11 Portable Shell Programming"](https://www.gnu.org/savannah-checkouts/gnu/autoconf/manual/autoconf-2.72/autoconf.html#Portable-Shell).
For more discussion see
[4.6 MISCELLANEUS NOTES](#46-miscellaneus-notes).

Let's first consider the typical `sh`
shells in order of their strictness to
POSIX:

- [posh](https://tracker.debian.org/pkg/posh).
  Minimal `sh`, Policy-compliant
  Ordinary SHell. Very close to POSIX.
  Stricter than
  [dash](https://tracker.debian.org/pkg/dash).
  Supports
  `local` keyword to define local
  variables in functions. The keyword
  is not defined in POSIX.

- [dash](https://tracker.debian.org/pkg/dash).
  Minimal `sh`, Debian Almquish Shell.
  Close to POSIX. Supports `local`
  keyword. The shell aims to meet the
  requirements of the Debian Linux
  distribution.
- [Busybox ash](https://www.busybox.net)
  is based on
  [dash](https://tracker.debian.org/pkg/dash)
  with some more
  features added. Supports `local`
  keyword. See ServerFault
  ["What's the Busybox default shell?"](https://serverfault.com/questions/241959/whats-the-busybox-default-shell)

Let's also consider what the `/bin/sh`
might be in different Operating
Systems. For more about the history of
the `sh` shell, see the well-rounded
discussion on StackExchange.
[What does it mean to be "sh compatible"?](https://unix.stackexchange.com/q/145522)

<!-- <contactme2016@tangentsoft.com> -->
[Picture](https://tangentsoft.com/misc/unix-shells.svg)
"Bourne Family Shells" by
[tangentsoft.com](tangentsoft.com)
<picture>
    <source srcset="https://tangentsoft.com/misc/unix-shells-large.png">
    <img src="pic/unix-shells.svg" alt="Bourne Family Shells" style="width:auto;">
</picture>

- On Linux, most distributions already
  use, or are moving towards using,
  `sh` as a symlink to
  [dash](https://tracker.debian.org/pkg/dash).
  Older Linux versions (Red Hat,
  Fedora, CentOS) used to have `sh` to
  be a symlink to `bash`.

- On the most conservative NetBSD,
  it is `ash`, the old
  [Almquist shell](https://en.wikipedia.org/wiki/Almquist_shell).
  On FreeBSD, `sh` is also `ash`.
  On
  [OpenBSD, sh](https://man.netbsd.org/sh.1) is
  [ksh93](https://tracker.debian.org/pkg/ksh93u+m)
  from the
  [Ksh family](https://en.wikipedia.org/wiki/KornShell).
- On many commercial, conservative
  UNIX systems `sh` is nowadays quite
  capable
  [ksh93](https://tracker.debian.org/pkg/ksh93u+m).
- On macOS, `sh` points to `bash
  --posix`, where the Bash version is
  indefinitely stuck at version 3.2.x
  due to Apple avoiding the GPL-3
  license in later Bash versions. If
  you write `/bin/sh` scripts in macOS,
  it is good idea to check them for
  portability with:

```bash
    # Check better /bin/sh
    # compliance

    dash -nx script.sh
    posh -nx script.sh
```

In practical terms, if you plan to aim
for POSIX-compliant shell scripts, the
best shells for testing would be
[posh](https://tracker.debian.org/pkg/posh)
and
[dash](https://tracker.debian.org/pkg/dash).
You can also extend testing
with BSD Ksh shells and other shells.
See
[FURTHER READING](#further-reading)
for external utilities to check and
improve shell scripts even more.

    # Save in shell startup file
    # like ~/.bashrc

    shelltest()
    {
        local script shell

        for script # Implicit "$@"
        do
            for shell in \
                posh \
                dash \
                "busybox ash" \
                mksh \
                ksh \
                bash \
                zsh
            do
                if command -v "$shell" > /dev/null; then
                    echo "-- shell: $shell"
                    $shell -nx "$script"
                fi
            done
        done
    }

    # Use is like:
    shelltest script.sh

    # External utility
    shellcheck script.sh

    # External utility
    checkbashisms script.sh

## 4.4 SHEBANG LINE IN SCRIPTS

Note that POSIX does not define the
[shebang](https://en.wikipedia.org/wiki/Shebang_(Unix))
— the traditional first line that
indicates which interpreter to use. See
POSIX C language's section "exec family
of functions" and
[RATIONALE](https://pubs.opengroup.org/onlinepubs/9799919799/functions/exec.html#:~:text=RATIONALE)

> (...) Another way that some
> historical implementations handle
> shell scripts is by recognizing the
> first two bytes of the file as the
> character string "#!" and using the
> remainder of the first line of the
> file as the name of the command
> interpreter to execute.

The first bytes of a script typically
contain two special ASCII codes, a
special comment `#!` if you wish, which
is read by the kernel. Note that this
is a de facto convention, universally
supported even though it is not defined
by POSIX.

    #! <interpreter> [word]
    #
    # 1. whitespace is allowed in
    #    "#!" for readability.
    #
    # 2. The <interpreter> must be
    #     full path name. Not like:
    #
    #    #! sh
    #
    # 3. ONE word can be added
    #    after the <interpreter>.
    #    Any more than that may not
    #    be portable accross Linux
    #    and some BSD Kernels.
    #
    #    #! /bin/sh -eu
    #    #! /usr/bin/awk -f
    #    #! /usr/bin/env bash
    #    #! /usr/bin/env python3

### 4.4.1 About Bash and Shebang

Note that on macOS, `/bin/bash` is
hard-coded to Bash version 3.2.57 where
in 2025 lastest Bash is
[5.2](https://tracker.debian.org/pkg/bash).
You cannot uninstall it, even with root
access, without disabling System
Integrity Protection. If you install a
newer Bash version with `brew install
bash`, it will be located in
`/usr/local/bin/bash`.

On macOS, to use the latest Bash, the
user must arrange `/usr/local/bin`
first in
[PATH](https://pubs.opengroup.org/onlinepubs/9799919799/basedefs/V1_chap08.html#:~:text=This%20variable%20shall%20represent%20the%20sequence%20of%20path%20prefixes).
If the script starts with `#!
/bin/bash`, the user cannot arrange it
to run under different Bash version
without modifying the script itself, or
after modifying `PATH`, run it
inconveniently with `bash <script>`.

    ... portable

    #! /usr/bin/env bash

    ... traditional

    #! /bin/bash

### 4.4.2 About Python and Shebang

There was a disruptive change from
Python 2.x to Python 3.x in 2008. The
older programs did not run without
changes with the new version. In Python
programs, the shebang should specify
the Python version explicitly, either
with `python` (2.x) or `python3`.

    ... The de facto interpreters

    #! /usr/bin/python
    #! /usr/bin/python3

    .... not supported

    #! /usr/bin/python2
    #! /usr/bin/python3.13.2

But this is not all. Python is one
of those languages which might require
multiple virtual environments based on
projects. It is typical to manage these
environments with tools like
[uv](https://docs.astral.sh/uv/pip/environments/)
or older
[virtualenv](https://virtualenv.pypa.io),
[pyenv](https://github.com/pyenv/pyenv)
etc. For even better portability, the
following would allow user to use his
active Python environment:

    ... portable

    #! /usr/bin/env python3

The fine print here is that
[`env`](https://pubs.opengroup.org/onlinepubs/9799919799/utilities/env.html)
is a standard POSIX utility, but its
path is not mandated by POSIX. However,
in 99.9% of cases, the de facto
portable location is `/usr/bin/env`.

## 4.5 PORTABILITY OF UTILITIES

In the end, the actual implementation
of the shell you use (dash, bash,
ksh...) is less important than what
utilities you use and how you use them.

It's not just about choosing to write
in POSIX `sh`; the utilities
called from the script also has to be
considered. Those of `echo`, `cut`,
`tail` make big part of of the scripts.
If you want to ensure portability,
check options defined in
[POSIX](https://pubs.opengroup.org/onlinepubs/9799919799/).
See top left menu "Shell & Utilities"
followed by bottom left menu
["4. Utilities"](https://pubs.opengroup.org/onlinepubs/9799919799/idx/utilities.html)

Notable observations:

- Use POSIX
  [`command -v`](https://pubs.opengroup.org/onlinepubs/9799919799/utilities/command.html)
  to check if command exists.
  Note that POSIX also defines
  [`type`](https://pubs.opengroup.org/onlinepubs/9799919799/utilities/type.html),
  as in `type <command>`
  without any options. POSIX also
  defines utility
  [`hash`](https://pubs.opengroup.org/onlinepubs/9799919799/utilities/type.html),
  as in `hash <command>`. Problem with
  `type` is that the semantics, return
  codes, support or output are not
  necessarily uniform. Problem with
  `hash` are similar. Neither `type`
  nor `hash` is supported by
  [posh](https://tracker.debian.org/pkg/posh);
  see table
  [RESULTS-PORTABILITY](./doc/RESULTS-PORTABILITY.txt).
  Note: The `which <command>` is
  neither in POSIX nor portable. For
  more information about `which`, see
  shellcheck
  [SC2230](https://github.com/koalaman/shellcheck/wiki/SC2230),
  BashFAQ [081](https://mywiki.wooledge.org/BashFAQ/081),
  StackOverflow discussion
  ["How can I check if a program exists from a Bash script?"](https://stackoverflow.com/q/592620),
  and Debian project plan about
  deprecating the command in LWN
  article
  ["Debian's which hunt"](https://lwn.net/Articles/874049/).

```bash
    REQUIRE="sqlite curl"

    RequireFeatures ()
    {
        local cmd

        for cmd # Implicit "$@"
        do
            if ! command -v "$cmd" > /dev/null; then
                echo "ERROR: not in PATH: $cmd" >&2
                return 1
            fi
        done
    }

    # Before program starts
    RequireFeatures $REQUIRE || exit $?
    ...
```

- Use plain
  [`echo`](https://pubs.opengroup.org/onlinepubs/9799919799/utilities/echo.html)
  without any options. Use
  [`printf`](https://pubs.opengroup.org/onlinepubs/9799919799/utilities/printf.html)
  when more functionality is needed.
  Relying solely on `printf` may not be
  ideal. In POSIX-compliant `sh` shells,
  `printf` is not always a built-in
  command (e.g., in
  [posh](https://tracker.debian.org/pkg/posh)
  or
  [mksh](https://tracker.debian.org/pkg/mksh))
  which can lead to performance overhead
  due to the need to invoke an external
  process.

```bash
    # POSIX
    echo "line"            # (1)
    echo "line"
    printf "no newline"    # (2)

    # Not POSIX
    echo -e "line\nline"   # (1)
    echo -n "no newline"   # (2)

```

- Use [`grep -E`](https://pubs.opengroup.org/onlinepubs/9799919799/utilities/grep.html).
  In 2001 POSIX removed `egrep`.

- [`read`](https://pubs.opengroup.org/onlinepubs/9799919799/utilities/read.html).
  POSIX requires a VARIABLE, so always
  supply one. In Bash, the command would
  default to variable `REPLY` if omitted.
  You should also always use option `-r`
  which is eplained in
  shellcheck [SC2162](https://github.com/koalaman/shellcheck/wiki/SC2162),
  BashFAQ [001](https://mywiki.wooledge.org/BashFAQ/001),
  POSIX [IFS](https://pubs.opengroup.org/onlinepubs/9799919799/utilities/V3_chap02.html#:~:text=A%20string%20treated%20as%20a%20list%20of%20characters)
  and
  BashWiki [IFS](https://mywiki.wooledge.org/IFS).
  See in depth details
  how the
  [`read`](https://www.gnu.org/software/bash/manual/html_node/Bash-Builtins.html#index-read)
  command does not reads characters and
  not lines in StackExchange discussion
  [Understanding "IFS= read -r line"](https://unix.stackexchange.com/a/209184).


```bash
   # POSIX
   REPLY=$(cat file)

   # Bash, Ksh
   # Read max 100 KiB to $REPLY
   read -N $((100 * 1024)) REPLY < file

   case $REPLY in
        *pattern*)
            # match
            ;;
   esac
```

- Use [`shift N`](https://pubs.opengroup.org/onlinepubs/9799919799/utilities/shift.html)
  always with shell special parameter
  [`$#`](https://pubs.opengroup.org/onlinepubs/9799919799/utilities/V3_chap02.html#tag_18_05_02)

```bash
    set -- 1

    # POSIX
    # shift all positional args
    shift $#

    # Any greater number terminates
    # the whole program in:
    # dash, posh, mksh, ksh93 etc.
    shift 2
```

### 4.5.1 Case Study: sed

As a case study, the Linux GNU `sed(1)`
 and its options differ or
are incompatible. The Linux GNU
[`sed`](https://www.gnu.org/software/sed/)
`--in-place` option for replacing file
content cannot be used in macOS and
BSD. Additionally, in macOS and BSD,
you will find GNU programs under a
`g`-prefix, such as `gsed(1)`, etc. See
StackOverflow
["sed command with -i option failing on Mac, but works on Linux"](https://stackoverflow.com/q/4247068). For more
discussions about the topic, see
StackOverflow [1](https://stackoverflow.com/q/48712373),
StackOverflow [2](https://stackoverflow.com/q/16745988),
StackOverflow [3](https://stackoverflow.com/q/7573368).

    # Linux (works)
    #
    # GNU sed(1). Replace 'this'
    # with 'that'

    sed -i 's/this/that/g' file

    # macOS (does not work)
    #
    # This does not work. The '-i'
    # option has different syntax
    # and semantics. There is no
    # workaround to make the '-i'
    # option work across all
    # operating systems.

    sed -i 's/this/that/g' file

    # Maybe portable
    #
    # In many cases Perl might be
    # available although it is not
    # part of the POSIX utilities.

    perl -i -pe 's/this/that/g' file

    # Portable
    #
    # Avoid -i option.

    tmp=$(mktemp)
    sed 's/this/that/g' file > "$tmp"
    mv "$tmp" file
    rm -f "$tmp"

### 4.5.2 Case Study: awk

POSIX
[`awk`](https://pubs.opengroup.org/onlinepubs/9799919799/utilities/awk.html),
does not support the `-v` option to
define variables. You can use
assignments after the program instead.

    # POSIX
    awk '{print var}' var=1 file

    # GNU awk
    awk -v var=1 '{print var}' file

However, don't forget that such
assignments are not evaluated until
they are encountered, that is, after
any `BEGIN` action. To use awk for
operands without any files:

    # POSIX
    var=1 awk 'BEGIN {print ENVIRON["var"] + 1}' < /dev/null

    # GNU awk
    awk -v var=1 'BEGIN {print var + 1; exit}'

## 4.6 MISCELLANEOUS NOTES

- The shell's null command
  [`:`](https://www.gnu.org/software/bash/manual/html_node/Bourne-Shell-Builtins.html)
  might be slightly preferrable than
  utlity
  [`true`](https://pubs.opengroup.org/onlinepubs/9799919799/utilities/true.html)
  according to
  GNU autoconf's manaual
  ["11.14 Limitations of Shell Builtins"](https://www.gnu.org/savannah-checkouts/gnu/autoconf/manual/autoconf-2.72/autoconf.html#Limitations-of-Builtins)
  which states that `:` might not be
  always builtin and "(...) the
  portable shell community tends to
  prefer using :".

```bash
    while :
    do
        break
    done

    # Create an empty file
    : > file

```

- Prefer POSIX
  [`$(cmd)`](https://pubs.opengroup.org/onlinepubs/9799919799/utilities/V3_chap02.html#tag_18_06_03)

  command substitution instead of
  leagacy POSIX backtics as in \`cmd\`.
  For more information, see
  BashFaq [098](https://mywiki.wooledge.org/BashFAQ/082)
  and shellcheck
  [SC2006](https://github.com/koalaman/shellcheck/wiki/SC2006).
  For 20 years all the modern `sh`
  shells have supported `$()`.
  Including UNIX like AIX, HP-UX and
  conservative Oracle Solaris 10 (2005)
  whose support ends in
[2026](https://www.theregister.com/2024/01/29/oracle_extends_solaris_support/#:~:text=During%202023%2C%20Oracle%20added%20another,2027%20instead%20of%20during%202024)
  (see Solaris
  [version history](https://www.liquisearch.com/solaris_operating_system/version_history)).

```bash
        # Easily nested
        lastdir=$(basename $(pwd))

        # Readabilty problems
        lastdir=`basename \`pwd\``
```

<!--
TODO:
https://www.gnu.org/savannah-checkouts/gnu/autoconf/manual/autoconf-2.72/autoconf.html#Shellology
-->

# 5.0 RANDOM NOTES

See the Bash manual how to use
[`time`](https://www.gnu.org/software/bash/manual/bash.html#Pipeline)
reserved word with
[TIMEFORMAT](https://www.gnu.org/software/bash/manual/bash.html#index-TIMEFORMAT)
variable to display results in
different formats. The use of time as a
reserved word permits the timing of
shell builtins, shell functions, and
pipelines.

    TIMEFORMAT='real: %R'  # '%R %U %S'

You could also drop kernel cache before
testing:

    echo 3 > /proc/sys/vm/drop_caches

# 6.0 FURTHER READING

## 6.1 BASH PROGRMAMING

- Bash
  [Manual](https://www.gnu.org/software/bash/manual/bash.html)
- Greg's Bash Wiki and FAQ
  https://mywiki.wooledge.org/BashGuide
- List of which features were added to
  specific releases of Bash
  https://mywiki.wooledge.org/BashFAQ/061

## 6.2 PORTABILITY AND UTILITIES

-  GNU autoconf's manaual section
  ["11 Portable Shell Programming"](https://www.gnu.org/savannah-checkouts/gnu/autoconf/manual/autoconf-2.72/autoconf.html#Portable-Shell)
  **Note:** This presents information
  intended to overcome operating system
  portability issues dating back to the
  1970s. Consider some tips with a grain
  of salt, given the capabilities of more
  modern POSIX-compliant shells.
- For cross platform detection, see
  useful files to check:
  http://linuxmafia.com/faq/Admin/release-files.html
- `shellcheck` (Haskell)
  can help to improve and write portable
  POSIX scripts. It can statically Lint
  scripts for potential mistakes. There
  is also a web interface where you can
  upload the script at
  https://www.shellcheck.net. In Debian,
  see package "shellcheck". The manual
  page is at
https://manpages.debian.org/testing/shellcheck/shellcheck.1.en.html
- `checkbashisms` can help to improve and
  write portable POSIX scripts. In
  Debian, the command is available in
  package "devscripts". The manual page
  is at
  https://manpages.debian.org/testing/devscripts/checkbashisms.1.en.html

## 6.3 STANDARDS

Relevant links from 2000 onward:

- https://en.wikipedia.org/wiki/POSIX
- POSIX.1-2024
  IEEE Std 1003.1-2024
  https://pubs.opengroup.org/onlinepubs/9799919799
- POSIX.1-2018
  IEEE Std 1003.1-2018
  https://pubs.opengroup.org/onlinepubs/9699919799
  https://pubs.opengroup.org/onlinepubs/9699919799.2018edition/
- POSIX.1-2008
  IEEE Std 1003.1-2008
  https://pubs.opengroup.org/onlinepubs/9699919799.2008edition/
- POSIX.1-2004 (2001-2004)
  IEEE Std 1003.1-2004
  https://pubs.opengroup.org/onlinepubs/009695399

## 6.3 MISCELLANEOUS LINKS

- A comprehensive history of `ash`.
  "Ash (Almquist Shell) Variants" by
  Sven Mascheck
  https://www.in-ulm.de/~mascheck/various/ash/
- Late Jörg Shillings's
  [schilitools](https://codeberg.org/schilytools/schilytools.git)
  contains `pbosh` shell that can be used
  for POSIX-sh-like testing.
  See discussion of preserving
  the project and some history at
  [Reddit](https://www.reddit.com/r/linux/comments/w9vrpx/continued_development_of_j%C3%B6rg_schillings_tools/?rdt=56420).
- Super simple `s` command interpreter
  to write shell-like scripts (security
  oriented):
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

License-tag: GPL-2.0-or-later<br>
See https://spdx.org/licenses

Keywords: shell, sh, POSIX, bash,
ksh, ksh93, programming,
optimizing, performance, profiling,
portability
