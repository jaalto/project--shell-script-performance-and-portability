#! /bin/bash
# Short: <<< HERE_STRING
# Desc: Test for HERE STRING <<< support
#
# Notes:
#
# Only HERE DOCUMENT syntax '<<' and '<<-' is defined in POSIX
# Url: https://pubs.opengroup.org/onlinepubs/9799919799.2024edition/utilities/V3_chap02.html#tag_19_07_04

: <<< "string"
