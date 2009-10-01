#!perl

# Copyright (C) 2006-2008, The Parrot Foundation.
# $Id: cmd_apply.t 26472 2008-03-18 14:27:51Z coke $

# the following lines re-execute this as a tcl script
# the \ at the end of these lines makes them a comment in tcl \
use lib qw(lib); # \
use Tcl::Test; #\
__DATA__

source lib/test_more.tcl

plan 8

eval_is {apply foo} \
  {can't interpret "foo" as a lambda expression} \
  {bad lambda expression}

eval_is {apply {foo bar baz bit}} \
  {can't interpret "foo bar baz bit" as a lambda expression} \
  {bad lamdba expression}

eval_is {apply {foo bar baz}} \
  {namespace "::baz" not found} \
  {namespace doesn't exist}

eval_is {apply} \
  {wrong # args: should be "apply lambdaExpr ?arg1 arg2 ...?"} \
  {too few args}

eval_is {apply {{foo {bar 2} {baz 3}}  bar}} \
  {wrong # args: should be "apply {{foo {bar 2} {baz 3}}  bar} foo ?bar? ?baz?"} \
  {too few args}

eval_is {apply {{}   bar} foo} \
  {wrong # args: should be "apply {{}   bar}"} \
  {too many args}

eval_is {apply {{n} {expr {$n*$n}}} {5}} 25 \
  {squaring function}

eval_is {
  unset -nocomplain x func
  set x 4
  set func {
    upvar 1 $var n
    set n [expr {$n + 1}]
  }
  apply [list {var {i 1}} $func] x
  set x
} 5 {incr}
