<!--
INFORMATION FOR EDITING

- Github Markdown Guide:
  https://is.gd/nqSonp

- View markdown in VSCode:
  Command Palette (C-S-p)
  Markdown: Open Preview C-S-v
  Markdown: Open Preview to the side C-k v
  [upper right:eye-icon button] Open Preview to the Side

- URL text fragments: #:~:text=
  https://developer.mozilla.org/en-US/docs/Web/URI/Reference/Fragment/Text_fragments

- About accessibility

  To support viewing and editing GitHub
  pages on phone displays, the maximum
  column widths are described below.
  Exception: The GNU License at the end
  of file is included verbatim.

  The maximum column limits are:

  col type
  ---------------------------------------
  35  Code: bullet: ``` ... ``´)
  41  Regular text and paragraphs.
      Github line limit to support
      editing.
  ---------------------------------------

  Emacs editor settings:

  ;; eval code with C-x C-e
  (progn
    (setq fill-column 41)
    (display-fill-column-indicator-mode 1))

MISCELLANEOUS

- To search POSIX.1-2024 in Google
  site:pubs.opengroup.org inurl:9799919799 <search>

-->

# USAGE

List all targets:

	make help

To extract results from test cases:

    make show

To re-run all tests:

    make run

Run portability tests:

    make portability

To run a single test case and display
commentary:

    cd bin

	# t-*  is a text case
	# x-*  is a portability test
    ./run.sh <test>.sh ...

# RUNNING UNDER DIFFERENT SHELL

To run the test cases under different
shells, use the `--shell SHELL` option.
Note that the shells must support the
built-in `time` command. The shell must
also support features tested in a test
case file, such as arrays, etc.

*Note*: unfortunately, `zsh` cannot be
used because its `time` can only call
binaries, not anot call test case
functions.

	./run.sh <test>.sh ...
	./run.sh --shell ksh <test>.sh ...
	./run.sh --shell mkksh <test>.sh ...
	./run.sh --shell dash,ksh,bash <test>.sh ...

# RUNNING MANUALLY

For running a test case manually "as is"
(usually under bash):

	cd bin
	./<test>.sh

	# To change loop count
	loop_max=200 ./<test>.sh

**WARNING:** The individual test case
files are not designed to run correctly
from any location other than the
directory they are located in. This is
due to their creation of temporary files
and directories in the same location.
E.g. The `$TMPDIR` is not used because it
might be on a RAM disk.

	# Use ...
	./<test>.sh
	./run.sh --shell dash <test>.sh

	dash bin/<file>.sh  # Don't
