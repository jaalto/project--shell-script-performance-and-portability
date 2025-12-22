
# t-command-echo-vs-printf.sh

**Q: The classic: `echo` vs `printf`**<br/>
*A: No notable difference*<br/>
_priority: 0_

    t1 real 0m0.272s echo
    t2 real 0m0.278s printf


# t-command-grep-parallel.sh

**Q: Is `grep' faster with `parallel`?**<br/>
*A: In typical files, grep is much faster. Use `parallel`only with huge files.*<br/>
_priority: 1_

    t0  real 0m0.005s grep baseline
    t1a real 0m0.210s --block-size <default> --pipepart
    t1b real 0m0.240s --block-size <default> (Linux)
    t2  real 0m0.234s --block-size 64k
    t3  real 0m0.224s --block-size 32k

## Notes

The idea was to split file into chunks and run
grep` in parallel for each chunk.

The `grep` by itself is very fast. The startup time
of `parallel`, implemented in `perl`, is taking the
toll with the parallel if the file sizes are
relatively small (test file: ~600 lines).


# t-command-grep.sh

**Q: In GNU grep, is option --fixed-strings faster?**<br/>
*A: No notable difference between --extended-regexp, --perl-regexp, --ignore-case*<br/>
_priority: 2_

    t1langc    real 0m0.382s LANG=C --fixed-strings
    t1utf8     real 0m0.389s LANG=C.UTF-8 --fixed-strings
    t1extended real 0m0.382s LANG=C --extended-regexp
    t1perl     real 0m0.381s LANG=C --perl-regexp

    t2icasef   real 0m0.386s LANG=C --ignore-case --fixed-strings
    t2icasee   real 0m0.397s LANG=C --ignore-case --extended-regexp

## Notes

The tests suggest that with 10 KiB file sizes,
the choice between the "C" locale and
UTF-8 is not significant. Similarly, the type of
regular expression or case sensitivity does not
seem to be a major factor.

However, on some operating systems and with large
files, there have been reports of significant
speed improvements by using the "C" locale,
enabling `--fixed-strings`, and avoiding
`--ignore-case`.


# t-command-output-vs-process-substitution.sh

**Q: `cmd | while` vs `while ... done < <(process substitution)`**<br/>
*A: No notable difference. Process substitution preserves variables in loop.*<br/>
_priority: 1_

    t1 real 0m0.670s  POSIX. cmd > file ; while ... < file
    t2 real 0m0.760s  Bash process substitution
    t3 real 0m0.780s  POSIX. cmd | while

## Code

    t1 cmd > file ;  while read -r ... done < file
    t2 while read -r ... done < <(cmd)
    t3 cmd | while read -r ... done

## Notes

There is no practical difference.

Process substitution is general because the
`while` loop runs under the same environment, and
any variables defined or set will persist
afer the loop.

Even though t1 (POSIX), which uses a temporary
file, seems to be faster, it really isn't. What is
not shown in the measurement is the extra `rm`
cleanup for the temporary file, which must be taken
into account, thus nullifying any perceived speed
gains.


# t-command-pwd-vs-variable-pwd.sh

**Q: How much is POSIX `$PWD` and `$OLDPWD` faster than `pwd`?**<br/>
*A: It is about 7x faster to `pwd`*<br/>
_priority: 2_

    t1 real 0.004 cd ...do.. ; cd $OLDPWD
    t2 real 0.006 olddir=$PWD ; cd ...do.. ; cd $olddir
    t3 real 0.011 pushd ; cd ...do.. ; popd
    t4 real 0.086 olddir=$(pwd) ; cd ...do.. ; cd $olddir

## Notes

Even though `pwd` is a Bash built-in, there
is still a penalty for calling command
substitution `$(command)`.


# t-dir-empty.sh

**Q: What is the fastest way to check empty directory?**<br/>
*A: array+glob is faster than built-in `compgen`*<br/>
_priority: 3_

    t1 real 0m0.054s   array+glob
    t2 real 0m0.104s   compgen
    t3 real 0m0.304s   ls
    t3 real 0m0.480s   find | read

## Code

    t1 files=("$dir"/*)
    t2 compgen -G "$dir"/*
    ...


# t-dir-entries.sh

**Q: Fastest to get list of dirs: loop vs `compgen` vs `ls -d`**<br/>
*A: No notable differences.`ls` is good enough.*<br/>
_priority: 1_

For 20 directories:

    t1 real 0m0.003s compgen -G */
    t2 real 0m0.001s for-loop
    t3 real 0m0.004s ls -d */
    t4 real 0m0.007s find . -maxdepth 1-type d

For 100 directories:

    t1 real 0m0.012s compgen -G */
    t2 real 0m0.015s for-loop
    t3 real 0m0.010s ls -d */
    t4 real 0m0.011s find . -maxdepth 1 -type d

## Notes

Because the OS caches files and directories, run
tests manually:

    max_dirs=20 ./t-dir-entries.sh t1
    max_dirs=20 ./t-dir-entries.sh t2
    max_dirs=20 ./t-dir-entries.sh t3
    max_dirs=20 ./t-dir-entries.sh t4


# t-file-copy-check-exist.sh

**Q: Should you test newer before copying?**<br/>
*A: It is about 40x faster is you test before copying.*<br/>
_priority: 1_

    t1 real 0m0.007s <file test> cp
    t2 real 0m1.270s cp A B

## Code

    t1 [ A -nt B ] || cp --preserve=timestamps ...
    t2 cp --preserve=timestamps A B


# t-file-for-loop-vs-awk.sh

**Q: for-loop file-by-file to awk vs awk handling all the files?**<br/>
*A: It is about 2-3x faster to do it all in awk*<br/>
_priority: 7_

    t1 real 0m0.213s awk '{...}' <file> <file> ...
    t1 real 0m0.584s for <files> do ... awk <file> ... done


# t-file-glob-bash-compgen-vs-stat.sh

**Q: How to check if GLOB matches any files: arrays vs `compgen` vs `stat`**<br/>
*A: `compgen` and array+glob are slightly faster than `stat`*<br/>
_priority: 2_

    t1 real 0m0.026s   Bash compgen GLOB
    t2 real 0m0.028s   Bash array: (GLOB)
    t3 real 0m0.039s   stat -t GLOB

## Code

    t1 compgen -G "file"*
    t2 arr=("file"*)
    t3 stat -t "file"*

## Notes

Command `stat` does more work by opening each found file.


# t-file-grep-vs-match-in-memory.sh

**Q: To search file for matches: in memory search vs `grep`**<br/>
*A: It is about 8-10x faster to read file into memory and then do matching*<br/>
_priority: 10_

    t1a real 0m0.049s read once + bash regexp (read file once + use loop)
    t1b real 0m0.054s read once + case..MATCH..esac (read file once + use loop)
    t2  real 0m0.283s grep
    t3  real 0m0.407s read + case..MATCH..esac (separate file calls)
    t4  real 0m0.440s read + bash regexp (separate file calls)

## Code

See the test code for more information. Overview:

    t1a read once and loop [[ str =~~ RE ]]
    t1b read once and loop case..MATCH..end
    t2  grep RE file in loop
    t3  read every time in loop. case..MATCH..end
    t4  read every time in loop. [[ str =~~ RE ]]

## Notes

Repeated reads of the same file
probably utilizes Kernel cache to some
extent. But it is still much faster to
read file once into memory and then
apply matching multiple times.

The `grep` command is leaps ahead of
re-reading the file in a loop and using
the shell’s own matching capabilities.

In Ksh, the "read into memory first, then
match" is extremely fast:

    t1a real 0.005  user 0.002  sys 0.002
    t1b real 0.334  user 0.328  sys 0.005
    t2  real 0.221  user 0.126  sys 0.096
    t3  real 0.478  user 0.343  sys 0.137
    t4  real 0.222  user 0.153  sys 0.071


# t-file-newest-in-dir.sh

**Q: What is the fastest way to get newest file in a directory**<br/>
*A: Use find + filters. find + awk would be tad faster but more complex.*<br/>
_priority: 3_

    t1 real 0m0.417s   find + awk
    t2 real 0m0.523s   find + sort + head + cut
    t3 real 0m0.575s   find + sort + sed

    t4 real 0m0.382s   stat (not a generic solution)
    t5 real 0m0.330s   ls -t (not a generic solution)

## Code

See the test code for more information. Overview:

    t1 find -maxdepth 1 -type f ... | awk '<complex code>'
    t2 find -maxdepth 1 -type f | sort -r | head -1 | cut ...
    t3 find -maxdepth 1 -type f | sort -r | sed ...
    t4 stat ... | sort -r | sed ...
    t5 ls --sort=time | head -1

## Notes

Interestingly `head` and `cut` combined was
faster than `sed`.

Commads `ls` and `stat` can't tell files from
directories, so they are not usable if a
directory contains both.


# t-file-pipe-vs-process-substitution.sh

**Q: Would pipe be slower than using process substitution?**<br/>
*A: No notable difference. Pipes are efficient.*<br/>
_priority: 0_

    t1 real 0m0.790s  pipes
    t2 real 0m0.745s  process substitution

## Code

    cmd | cmd | cmd           # t1
    < <( < <(cmd) cmd) cmd    # t2


# t-file-read-cat-vs-bash.sh

**Q: Howabout `$(< FILE)` vs `$(cat FILE)`**<br/>
*A: It is about 2x faster to use `$(< FILE)` for small files*<br/>
_priority: 10_

    t1 real 0m0.166s $(< file)
    t2 real 0m0.365s $(cat file)

## Notes

With big files, they are equal.

    . ./t-lib.sh; RandomWordsDictionary 1M > t.1M

    time bash -c 's=$(cat t.1M); echo "$s" > /dev/null'
    real 0m0.059s

    time bash -c 's=$(< t.1M); echo "$s" > /dev/null'
    real 0m0.056s


# t-file-read-content-loop.sh

**Q: To process lines: `readarray` vs `while read < file`**<br/>
*A: It is about 2x faster to use `readarray`*<br/>
_priority: 6_

    t1  real 0m0.037s t1  mapfile + for
    t2a real 0m0.036s t2a readarray + for
    t2b real 0m0.081s t2b readarray + for ((i++))
    t3  real 0m0.085s t3  while read < file

## Code

    t1  mapfile -t array < file   ; for <array> ...
    t1a readarray -t array < file ; for i in <array> ...
    t1b readarray -t array < file ; for ((i... <array> ...
    t1  while read ... done < file

## Notes

In Bash, the `readarray` built-in is a synonym for `mapfile`,
so they should behave equally.


# t-file-read-into-string.sh

**Q: To read file into string: `$(< file)` vs `read -N` vs `str=$(cat file)`**<br/>
*A: It is about 2x faster to use `$(< file)´*<br/>
_priority: 5_

    t1  real 0m0.170s $(< file)    Bash
    t2  real 0m0.320s read -N      non-POSIX shells
    t1  real 0m0.390s cat          POSIX


# t-file-read-match-lines-loop-vs-grep.sh

**Q: Use `grep` to prefilter before loop?**<br/>
*A: It is about 2x faster to use `grep` than doing all in a loop*<br/>
_priority: 7_

    t1a real 0m4.420s  grep prefilter before loop
    t1b real 0m5.050s  grep prefilter before loop (process substitution)
    t2a real 0m11.330s loop: POSIX glob match with case...esac
    t2b real 0m11.300s loop: Bash glob match using [[ ]]

## Code

    t1a grep | while ... done
    t1b while ... done < <(grep)
    t2a while read ... case..esac ... done < file
    t2b while read ... [[ ]] ... done < file

## Notes

In Bash, the preferred one is the
`while read do .. done < <(proc)` due to
variables being visible in the same scope.

The `grep | while` would create a subshell
and release the variables after the
for-loop.

_About the test cases_

The file contents read during the test cases are
probably cached in the Kernel. When the tests are
executed in the order "t1a t1b," reversing the
order to "t1b t1a" results in the FIRST test
consistently appearing to run faster. This is
likely not an accurate representation of the true
performance. The apparent equality in performance
between cases "t1a" and "t2b" is probably due to
the Kernel's file cache.


# t-file-read-shell-result.sh

**Q: Capturing command's output: `var=$()` vs reading from a temporary file?**<br/>
*A: It is about 2x faster to use `var=$()`*<br/>
_priority: 8_

    t1 real 0m0.428s val=$(cmd)
    t2 real 0m0.899s cmd > file; val=$(< file)


# t-file-read-with-size-check.sh

**Q: Is empty file check useful before reading file's content?**<br/>
*A: No need to check. Reading even empty file is fast.*<br/>
_priority: 0_

    t1 real 0m0.166s $(< file)
    t2 real 0m0.168s [ -s file] && $(< file)


# t-file-size-info.sh

**Q: What is the fastest way to read a file's size?**<br/>
*A: Use `stat` or portable GNU `wc -c`.*<br/>
_priority: 5_

    t1 real 0m0.288s stat -c file
    t2 real 0m0.380s wc -c file; GNU version efectively is like stat
    t3 real 0m0.461s ls -l + awk

## Notes

If you don't need portability, `stat` is the
fastest. The caveat is that it is not defined in
POSIX, and the options differ from one operating
system to another.


# t-function-return-value-nameref.sh

**Q: To return value from function: nameref vs `val=$(funcall)`**<br/>
*A: It is about 8x faster to use nameref to return value from a function*<br/>
_priority: 10_

    t1 real 0m0.005s t2 funcall Bash nameref
    t2 real 0m0.006s t2 funcall POSIX nameref
    t3 real 0m0.055s t1 $(funcall)

## Code

    t1 fn(): local -n ret=$1; ... ret=$value
    t2 fn(): ret=$1; ... eval "$ret=\$value"
    t3 fn(): ... echo "<value>"

## Notes

In Bash, calling functions using
`$()` is expensive.

In Ksh, `$()` does not slow down the
code, and the times for t1 and t2 are
the same.

It is possible to use `eval` to emulate
Bash's nameref `local -n var=...` syntax.
However, the POSIX approach is problematic
with nested function call chains, where each
nameref must have a unique variable name.

  fn11: nameref1
    fn2: nameref2
      ...


# t-statement-arithmetic-for-loop.sh

**Q: for-loop: `{1..N}` vs `$(seq N)` vs `((...i++))` vs POSIX `i=$((i + 1))`**<br/>
*A: The `$(seq N)` is fast in all shells. In ksh `{1..N}` is very slow.*<br/>
_priority: 2_

    t1 real 0m0.003s for i in {1..N}
    t2 real 0m0.004s for i in $(seq ...)
    t3 real 0m0.006s for ((i=0; i < N; i++))
    t4 real 0m0.010s while [ $i -le $N ] ... i=$((i + 1))

## Notes

Surprisingly, a simple, elegant, and practical winner
is `$(seq N)`.

The is a problem with `{N..M}`. The Bash brace
expansion cannot be parameterized, so it
is only useful if N is known beforehand.

However, all loops are so fast that the
numbers don't mean much. The POSIX while-loop
variant was slightly slower in all subsequent
tests.


# t-statement-arithmetic-increment.sh

**Q: POSIX `i=$((i + 1))` vs `((i++))` vs `let i++` etc.**<br/>
*A: No noticeable difference, POSIX `i=$((i + 1))` will do fine*<br/>
_priority: 10_

    t1  real 0m0.045s i=$((i + 1)) POSIX
    t2a real 0m0.072s : $((i + 1)) POSIX (side effect)
    t2b real 0m0.063s : $((i++))   POSIX (side effect)
    t3  real 0m0.039s ((i++))      Bash
    t4  real 0m0.053s let i++      Bash

## Notes

The tests were using 10 000 repeats, which is
unrealistic for any program. There really is no
practical difference whichever you choose. The
portable POSIX version works in all shells:
`i=$((i + 1))`.

When run under `ksh93`, the tests seems be
optimized for  `((...))` operator which is
about 2x faster:

    t1  real 0m0.029s i=$((i + 1)) POSIX
    t2a real 0m0.044s : $((i + 1)) POSIX (side effect)
    t2b real 0m0.044s : $((i++))   POSIX (side effect)
    t3  real 0m0.014s ((i++))      Bash
    t4  real 0m0.034s let i++      Bash


# t-statement-conditional-if-short-circuit-vs-nested.sh

**Q: if test && test vs nested if statements**<br/>
*A: No difference whatsoever.*<br/>
_priority: 0_

    t1        real 0m0.010s case with default
    t2        real 0m0.008s case without default

## Notes

As all would guess, there should not be any
difference. Out of curiosity the test was run
with 10 000 loop iterations just to stress out
the shell interepreters.

     ./run.sh --shell dash,ksh,bash --loop-max 10000 ./t-statement-conditional-if-short-circuit-vs-nested.sh

     Run shell: dash
     t1       real 0.051  user 0.053  sys 0.000
     t2       real 0.043  user 0.044  sys 0.000
     Run shell: ksh
     t1       real 0.017  user 0.017  sys 0.000
     t2       real 0.021  user 0.019  sys 0.001
     Run shell: bash
     t1       real 0.157  user 0.154  sys 0.003
     t2       real 0.139  user 0.136  sys 0.003


# t-statement-conditional-if-test-posix-vs-bash-double-bracket.sh

**Q: POSIX `[ $var = 1 ]` vs Bash `[[ $var = 1 ]]` etc**<br/>
*A: No notable difference.*<br/>
_priority: 0_

    t1val     real 0m0.002s [ "$var" = "1" ] # POSIX
    t2val     real 0m0.003s [[ $var = 1 ]]   # Bash

    t1empty   real 0m0.002s [ ! "$var" ]     # modern POSIX
    t2empty   real 0m0.002s [ -z "$var" ]    # archaic POSIX
    t3empty   real 0m0.003s [[ ! $var ]]     # Bash

## Notes

Only with very high amount of repeats, there are
slight differences in favor of Bash `[[ ]]`.

    loop_max=10000 ./statement-if-posix-vs-bash.sh

    t1val          real 0.055  user 0.054  sys 0.000  POSIX
    t2val          real 0.032  user 0.030  sys 0.003  [[ ]]

    t1empty        real 0.052  user 0.045  sys 0.007  POSIX
    t2empty        real 0.053  user 0.050  sys 0.003
    t3empty        real 0.032  user 0.026  sys 0.007  [[ ]]


# t-string-file-path-components.sh

**Q: Extract /path/file.txt to components: parameter expansion vs `basename` etc.**<br/>
*A: It is 10-40x faster to use in memory parameter expansion where possible*<br/>
_priority: 10_

    t1aBase real 0.007  parameter expansion
    t1bBase real 0.298  basename

    t2aDir  real 0.007  parameter expansion
    t2bDir  real 0.282  dirname

    t3aExt  real 0.004  parameter expansion
    t3bExt  real 0.338  cut with Bash HERE STRING
    t3bExt  real 0.336  cut
    t3cExt  real 0.411  awk
    t3dExt  real 0.425  sed

## Code

    t1aBase  ${str##*/}
    t1bBase  basename "$str"

    t2aDir   ${str%/*}
    t2bDir   dirname "$str"

    t3aExt   ${str#*.}
    t3bExt   cut --delimiter="." --fields=2,3 <<< "$str"
    t3cExt   echo "$str" | cut --delimiter="." --fields=2,3
    t3dExt   awk -v s="$str" 'BEGIN{$0 = s; sub(/^[^.]+./, ""); print; exit}'
    t3eExt   echo "$str" | sed --regexp-extended 's/^[^.]+//'

## Notes

It is obvious that doing everything in memory
using POSIX parameter expansion is very
fast. Seeing the measurements, and just how expensive it is,
reminds us to utilize the possibilities of
[parameter expansion](https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameter-Expansion)
more effectively in shell scripts.

It's not surprising that `echo "$str" | cut`
perform practically the same as Bash HERE
STRINGS in `cut <<< "$str"` use pipes under
the hood in lastest Bash versions. See
version 5.1 and section "c" in
https://github.com/bminor/bash/blob/master/CHANGES

**Notes**

Please note that you have to run the test
set multiple times to get an idea of relative
positions. The milliseconds vary a lot from
run to run. The overall picture is that heavier
tools `awk` is latert and `sed' remains last.

In the tests, we assume that directory names
do not contain the dot (`.`) characters.
Therefore the tests do not aim to present generic
solutions to expand all paths like:

    /path/project.git/README.txt


# t-string-match-pattern.sh

**Q: Match string by pattern: `[[ str == pattern ]]` vs case..esac**<br/>
*A: No noticeable difference, both are very fast*<br/>
_priority: 0_

    t1 real 0m0.002s Bash
    t2 real 0m0.003s case..esac

## Code

    t1 [[ $str == $pattern ]]
    t2 case... $pattern) ... esac

## Notes

  Bash's version is much more compact.


# t-string-match-regexp.sh

**Q: Match string by regexp: Bash `[[ s =~ re ]]` vs `expr` vs `grep`**<br/>
*A: It is 100x faster to use Bash. expr is 1.3x faster than grep*<br/>
_priority: 10_

    t1 real 0m0.002s [[ STRING =~ RE ]] Bash
    t2 real 0m0.220s expr RE : STRING
    t1 real 0m0.290s echo STRING | grep -E RE

## Code

    t1 [[ $str =~ $re ]]
    t2 expr match ".*$str" "$re"
    t3 echo "$str" | grep "$re"

## Notes

  Bash doing it all in memory, is very very
  fast. For POSIX `sh` shells, the `expr`
  is much faster than `grep.


# t-string-trim-whitespace.sh

**Q: Trim whitepace using Bash REGEXP vs `sed`**<br/>
*A: It is 8x faster to use Bash, especially with fn() nameref*<br/>
_priority: 7_

    t1 real 0m0.025s Bash fn() RE, using nameref to return value
    t2 real 0m0.107s Bash fn() RE
    t1 real 0m0.440s echo | sed RE

## Code

    t1 BashTrim var                    # fn() using nameref
    t2 var=$(bashTrim "$str")          # fn() return by value
    t3 var=$(echo "$str" | sed <trim>) # subshell call


# t-variable-array-split-string.sh

**Q: Split string into an array by IFS?**<br/>
*A: It is about 10x faster to use IFS+array than to use Bash array `<<<` HERE STRING*<br/>
_priority: 8_

    t1a real  0.011 Bash fn(): IFS=... eval array=(string)
    t1b real  0.011 IFS=... eval array=(string)
    t2  real  0.021 IFS+save arr=(string) IFS+restore
    t3  real  0.098 read -ra arr <<< string

## Code

    t1a Bash fn(): IFS=":" eval 'array=($PATH)'
    t1b IFS=":" eval 'array=($PATH)'
    t2  saved=$IFS; IFS=":"; array=($PATH)'; IFS=$saved
    t3  IFS=":" read -ra array <<< "$PATH"

## Notes

This test involves splitting by an arbitrary
character, which requires setting a local
`IFS` for the execution of the command.

The local IFS can be defined for one
statement only if `eval` is used.

The reason why `<<<` is slower is that it
uses a pipe buffer (in latest Bash),
whereas `eval` operates entirely in memory.

*Warning*

Please note that using the `(list)`
statement will undergo pathname expansion.
Use it only in situations where the string does
not contain any globbing characters
like `*`, `?`, etc.

You can prevent `(list)` to undergo pathname
expansion inside function, by disabling it with:

    local - set -f

