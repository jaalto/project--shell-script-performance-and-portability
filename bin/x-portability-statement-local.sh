#! /bin/bash
# Short: local
# Desc: Test local keyword in functions

fn ()
{
    local a=0
}

a=1
fn
ret=${a:-0}

[ "$ret" = 1 ]
