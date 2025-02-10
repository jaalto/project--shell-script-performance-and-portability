DESCRIPTION

    Some Bash/sh scripting performance tests.

    Tests to check if some way would be
    better than the other.

    Run from currect directory:

	./<script>.sh

    WARNING: not designed to work corrctly with:

	bash ~/path/to/<script>.sh

GENERAL PERFORMANCE TIPS

    - Avoid extra processes at all costs. Use
      buitins. Use arrays in for loops. Use
      name refs (Bash) to return value from
      functions.

    - If you can, read file into memory as a
      STRING and use bash regexp tests on STRING.
      This is much faster than calling grep(1).

    - For line-to-line handling, Read file
      once into an bash array and
      then loop array (in memory).

      It's faster than doing:
      "while read ... done < FILE".

    - Use prefilter grep as in:
         "grep ... | while read -r ...done".
      Much faster than filtering lines
      inside loop (contine, or if...fi).

NOTES

    See bash(1) manual for dislaying 'time' command
    results:

	TIMEFORMAT='real: %R'  # '%R %U %S'

    You could drop kernel cache before testing:

	echo 3 > /proc/sys/vm/drop_caches

CODE NOTES

    Files:

    - Readable shebang with space "#! <interpreter>"
    - All test files start with prefix "t-" for short.
    - Files ending to *.bash are specific to Bash.
    - Files ending to *.sh can be run under POSIX
      compliant shells.

    Variables and Linting:

    - Variables are *not* "$quoted" for simplicity.
    - shellcheck(1) is deliberately not used
      because files are intended to be as straightforward
      as possible. Ref: <https://www.shellcheck.net>.

    Coding Style

    - Allman for these:

	fn ()
	{
	    ...
	}

	for <test>
	do
	    ...
	done

	case "$var" in
	    glob) ...
		  ;;
	    glob) ...
		  ;;
	fi

    - K&R for placing 'then' in short conditionals:

	if <cmd>; then
	    ...
	fi

END OF FILE
