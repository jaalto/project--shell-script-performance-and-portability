#! /bin/bash
# Short: let
# Desc: Test 'let' keyword

i=0
let i++

[ "$i" = 1 ]
