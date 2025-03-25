#! /bin/bash
# Short: local
# Desc: Test local keyword in functions

fn ()
{
    local a=0
}

i=1
fn
var=${i:-0}

[ "$var" = 1 ]
