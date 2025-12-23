#! /bin/bash
# Short: local IFS
# Desc: Test 'local' keyword with IFS in functions

fn ()
{
    local IFS
    IFS=""
}

IFS=1
fn

[ "$IFS" = 1 ]
