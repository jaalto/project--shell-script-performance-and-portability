DESCRIPTION

    When writing shell scripts, what kind of
    constructs would make it more efficient?
    Here are some tests to check if A is
    better than B.

    NOTE: the absolute timing values are not
    really ineresting, but the the winning
    order.

GENERAL THOUGHTS

    Avoid calling extra processes.

	E.g. reading file into memory as
	STRING + bash regexp test on STRING
	is much faster than calling grep(1).

    Read file once into an bash array and
    then loop array (in memory).

	It's faster than doing the "while
	read ... done < FILE".

End of file
