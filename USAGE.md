# USAGE

To extract results from test cases:

    make show

To re-run all tests:

    make run

Run portability tests:

    make portability

To run test case and display commentary:

    cd bin/
    ./run.sh <test>.sh ...

# RUNNING UNDER DIFFERENT SHELL

To run the test cases under different shells,
use the `--shell SHELL` option. Note that the
shells must support the built-in `time` command.
The shell must also support features tested
in a test case file, such as arrays, etc.

*Note*: unfortunately, `zsh` cannot
be used because its `time` can only
call binaries, not test case functions.

	./run.sh <test>.sh ...
	./run.sh --shell ksh <test>.sh ...
	./run.sh --shell mkksh <test>.sh ...

# RUNNING MANUALLY

For running test cases manually:

	cd bin/
	./<test>.sh

	# To change loop count
	loop_max=200 ./<test>.sh

WARNING: The individual test case files
are not designed to work correctly from
anywhere else than the directory they
are located in. This is due to creating
temporary files and directories in the
same location. The `TMPDIR` is not used
because it might be on a RAM disk.

	# Use ...
	./<file>.sh

    # Do not use
	bash bin/<file>.sh
