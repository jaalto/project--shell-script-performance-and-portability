#! /bin/bash
# Short: local IFS
# Desc: Test 'local' keyword with IFS in functions

IFS="1"

fn ()
{
    local IFS=""  # Change temporarily
}

fn

[ "$IFS" = 1 ]
