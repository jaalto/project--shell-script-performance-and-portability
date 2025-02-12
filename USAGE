USAGE

    To display results:

        make show

    To re-run all tests:

        make run

    To run test and display commentary:

        cd bin/
        ./run.sh <test>.sh ...

    Run the test cases under different shells. The
    shells must have a built-in `time` command and
    support the tested features, such as array tests.
    Note: unfortunately, `zsh(1)` cannot be used
    because it cannot time function definitions.

        ./run.sh <test>.sh ...
        ./run.sh --shell ksh <test>.sh ...
        ./run.sh --shell mkksh <test>.sh ...

    For low level control:

        cd bin/
        ./<test>.sh

        # to chnange test rounds count
        loop_max=200 ./<test>.sh

    WARNING: The individual test files
    are not designed to work correctly with
    calls like:

        bash bin/<file>.sh

End of file
