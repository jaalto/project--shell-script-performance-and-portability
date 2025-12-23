#! /bin/bash
# Short: local
# Desc: Test 'local' keyword in functions

fn ()
{
    local i
    i=2
}

i=1
fn

[ "$i" = 1 ]
