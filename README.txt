DESCRIPTION

    Some Bash scripting performance tests.

    Tests to check if some way would be
    better than the other.

GENERAL THOUGHTS

    - Avoid calling extra processes.

    - If you can, read file into memory as
      a STRING and use bash regexp test on STRING.
      This is much faster than calling grep(1).

    - Read file once into an bash array and
      then loop array (in memory).

      It's faster than doing the "while
      read ... done < FILE".

NOTES

    See bash(1) manual for dislaying 'time' command
    results:

	TIMEFORMAT='real: %R'  # '%R %U %S'

    You could drop kernel cache before testing:

	echo 3 > /proc/sys/vm/drop_caches

CODE NOTES

    All test files start with prefix "t-" for short.

END OF FILE
