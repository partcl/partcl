#!perl

# Copyright (C) 2004-2006, The Parrot Foundation.

# the following lines re-execute this as a tcl script
# the \ at the end of these lines makes them a comment in tcl \
use lib qw(lib); # \
use Tcl::Test; #\
__DATA__

source lib/test_more.tcl
plan 9

eval_is {
 set a 2
 expr $a
} 2 {set}

eval_is {
 set a 1
 set a
} 1 {get}

eval_is {
  catch {unset a}
  set a
} {can't read "a": no such variable} \
  {missing global}

eval_is {
 set b 1
 set b(c) 2
} {can't set "b(c)": variable isn't array} \
  {not an array}

eval_is {
  array set a {}
  set a foo
} {can't set "a": variable is array} \
  {variable is array}

eval_is {
  array set test {4 ok}
  set {test(4)}
} ok {array access}

eval_is {set} \
  {wrong # args: should be "set varName ?newValue?"} \
  {no args}

eval_is {set a b c} \
  {wrong # args: should be "set varName ?newValue?"} \
  {too many args}

eval_is {set ::a::b::c 1} \
  {can't set "::a::b::c": parent namespace doesn't exist}
  {namespaces don't auto-vivify}
