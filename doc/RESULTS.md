
# t-command-grep-parallel.sh

**Q: Howabout using `parallel` to speed up `grep`?**<br/>
*A: `parallel` won't help in typical cases. Use only with huge files.*<br/>
_priority: 1_

    t0  real 0m0.005s grep baseline
    t1a real 0m0.210s --block-size <default> --pipepart
    t1b real 0m0.240s --block-size <default> (Linux 64k)
    t2  real 0m0.234s --block-size 64k (grep instance for every 1k lines)
    t3  real 0m0.224s --block-size 32k

## Notes

The idea was to split file into chunks and run
grep` in parallel for each chunk.

The `grep` by itself is very fast. The startup time
of `parallel`, implemented in `perl`, is taking the
toll with the parallel if the file sizes are
relatively small (test file: ~600 lines).


# t-command-grep.sh

**Q: In grep, is option --fixed-strings faster?**<br/>
*A: No real difference between --extended-regexp, --perl-regexp, --ignore-case*<br/>
_priority: 2_

    t1pure     real 0m0.382s LANG=C --fixed-strings
    t1utf8     real 0m0.389s LANG=C.UTF-8 --fixed-strings
    t1extended real 0m0.382s LANG=C --extended-regexp
    t1perl     real 0m0.381s LANG=C --perl-regexp

    t2icasef   real 0m0.386s LANG=C --ignore-case --fixed-strings
    t2icasee   real 0m0.397s LANG=C --ignore-case --extended-regexp


# t-command-output-vs-process-substitution.sh

**Q: `cmd | while` vs `while ... done < <(process substitution)`**<br/>
*A: No real difference. Process substitution preserves variables in loop.*<br/>
_priority: 0_

    t1 real 0m0.750s  cmd | while
    t2 real 0m0.760s  process substitution

## Code

    t1 cmd | while read -r ... done
    t2 while read -r ... done < <(cmd)

## Notes

There is no practical difference.

Process substitution is more general because the
`while` loop runs under the same environment, and
any variables defined or set will persist
afterward.


# t-command-pwd-vs-variable-pwd.sh

**Q: How much is POSIX `$PWD` faster than `pwd`?**<br/>
*A: It is about 7x faster to use `$PWD` to `pwd` (Bash built-in)*<br/>
_priority: 4_

    t1 real 0m0.010s olddir=$PWD ; cd ...do.. ; cd $olddir
    t2 real 0m0.075s olddir=$(pwd) ; cd ...do.. ; cd $olddir

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
*A: `ls` is good enough. No real differences.*<br/>
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

**Q: Should you test existense before copying?**<br/>
*A: It is about 5x faster is you test existense before copying.*<br/>
_priority: 5_

    t1 real 0m1.002s cp A B
    t2 real 0m0.013s <file test> cp
    t2 real 0m0.009s <file test> cp (hardlink)

## Code

    t1 cp --preserve=timestamps A B
    t2 [ A -nt B ] || cp --preserve=timestamps ...
    t3 [ A -ef B ] || cp --preserve=timestamps --link ...


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
    t2 real 0m0.039s   stat -t GLOB

## Code

    t1 compgen -G "file"*
    t2 arr=("file"*)
    t3 stat -t "file"*

## Notes

Command `stat` does more work by opening each found file.


# t-file-grep-vs-match-in-memory.sh

**Q: To search file for matches: in memory searh vs `grep`**<br/>
*A: It is about 8-10x faster to read file into memory and then do matching*<br/>

    t1a real 0m0.049s read + bash regexp (read file once + use loop)
    t1b real 0m0.117s read + case..MATCH..esac (read file once + use loop)
    t2  real 0m0.482s read + case..MATCH..esac (separate file calls)
    t3  real 0m0.448s read + bash regexp (separate file calls)
    t4  real 0m0.404s external grep

## Code

See the test code for more information. Overview:

    t1a read once and loop [[ str =~~ RE ]]
    t1b read once and loop case..MATCH..end
    t2  read -N<max> < file. case..MATCH..end
    t3  read -N<max> < file. [[ str =~~ RE ]]
    t4  grep RE file

## Notes

Repeated reads of the same file probably utilizes
Kernel cache to some extent. But it is still much faster
to read file once and then apply matching.


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
*A: No real difference. Pipes are efficient.*<br/>
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


# t-file-read-match-lines-loop-vs-grep.sh

**Q: Howabout using `grep` to prefilter before loop?**<br/>
*A: It is about 2x faster to use `grep` than doing all in a loop*<br/>
_priority: 7_

    t1a real 0m0.436s grep prefilter before loop
    t1b real 0m0.469s grep prefilter before loop (proc)
    t2a real 0m1.105s loop: POSIX glob match with case...esac
    t2b real 0m1.127s loop: Bash glob match using [[ ]]

## Code

    t1a grep | while ... done
    t1b while ... done < <(grep)
    t2a while read ... case..esac ... done < file
    t2b while read ... [[ ]] ... done < file

## Notes

The practical winner in scripts is the
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
*A: It is about 10x faster to use `[ -s file ]` before reading*<br/>
_priority: 8_

    t1 real 0m0.105s $(< file)
    t2 real 0m0.006s [ -s file] && $(< file)


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


# t-function-return-value.sh

**Q: To return value from function: nameref vs `val=$(funcall)`**<br/>
*A: It is about 40x faster to use nameref to return value from a function*<br/>
_priority: 10_

    t1 real 0m0.089s t1 $(funcall)
    t2 real 0m0.002s t2 funcall nameref

## Code

    t1 fn(): ... echo "<value>"
    t2 fn(): local -n ret=$1; ... ret="<value>"


# t-statement-arithmetic-for-loop.sh

**Q: for-loop: `{1..N}` vs `$(seq N)` vs `((...))` vs POSIX `i++`**<br/>
*A: The `{1..N}` and `$(seq N)` are very fast*<br/>
_priority: 2_

    t1 real 0m0.003s for i in {1..N}
    t2 real 0m0.004s for i in $(seq ...)
    t3 real 0m0.006s for ((i=0; i < N; i++))
    t4 real 0m0.010s while [ $i -le $N ] ... i++

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
_priority: 1_

    t1 real 0m0.025s ((i++))      Bash
    t2 real 0m0.047s let i++      Bash
    t3 real 0m0.045s i=$((i + 1)) POSIX
    t4 real 0m0.061s : $((i++))   POSIX (true; with side effect)

## Notes

The tests were using 10 000 repeats, which is
unrealistic for any program. There really is no
practical difference whichever you choose. The
portable POSIX version works in all shells:
`i=$((i + 1))`.


# t-statement-if-test-posix-vs-bash.sh

**Q: POSIX `[ $var = 1 ]` vs Bash `[[ $var = 1 ]]` etc**<br/>
*A: In practise, no real differences*<br/>
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


# t-string-file-path-component-explode.sh

**Q: Extract /path/file.txt componens: parameter expansion vs ´basename` etc.**<br/>
*A: It is 20-40x faster to use in memory parameter expansion where possible*<br/>
_priority: 10_

    t1aBase real 0.007  parameter expanion
    t1bBase real 0.298  basename
    t2aDir  real 0.007  parameter expanion
    t2bDir  real 0.282  dirname
    t3aExt  real 0.004  parameter expanion
    t3bExt  real 0.393  cut
    t3cExt  real 0.430  awk
    t3dExt  real 0.460  sed

## Code

    t1aBase  ${str##*/}
    t1bBase  basename "$str"
    t2aDir   ${str%/*}
    t2bDir   dirname "$str"
    t3aExt   ${str#*.}
    t3bExt   echo "$str" | cut --delimiter="." --fields=2,3
    t3cExt   awk -v s="$str" 'BEGIN{$0 = s; sub("^[^.]+.", ""); print; exit}'
    t3dExt   echo "$str" | sed --regexp-extended 's/^[^.]+//'

## Notes

It is obvious that doing everything in memory is very
fast. Seeing the measurements, and just how expensive it is,
reminds us to utilize the possibilities of
[parameter expansion](https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameter-Expansion)
more effectively in shell scripts.

In the tests, we assume that directory names
do not contain the dot (`.`) character.

The tests do not aim to present generic
solutions to expand all paths like:

    /path/project.git/README.txt


# t-string-trim-whitespace.sh

**Q: Trim whitepace using Bash RE vs `sed`**<br/>
*A: It is 8x faster to use Bash, especially with fn() nameref*<br/>
_priority: 10_

    t2 real 0m0.025s Bash fn() RE, using nameref for return value
    t2 real 0m0.107s Bash fn() RE
    t1 real 0m0.440s echo | sed RE

## Code

    t1 BashTrim var                    # fn() using nameref
    t2 var=$(bashTrim "$str")          # fn() return by value
    t3 var=$(echo "$str" | sed <trim>) # subshell call


# t-variable-array-split-string.sh

**Q: Split string into an array by IFS?**<br/>
*A: It is about 4-5 times faster to save/restore IFS than use Bash array `<<<` injecton*<br/>
_priority: 8_

    t1 real 0m0.005s (array)
    t2 real 0m0.011s IFS= eval ...
    t3 real 0m0.030s read -ra

## Code

    t1 saved=$IFS; IFS=":"; array=($PATH)'; IFS=$saved
    t2 IFS=":" eval 'array=($PATH)'
    t3 IFS=":" read -ra array <<< "$PATH"

## Notes

This test must be run separately to clear the
string from memory between invocations:

     for i in t{1..3}; do ./t-variable-array-split-string.sh $i; done

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

