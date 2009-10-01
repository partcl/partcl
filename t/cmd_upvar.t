#!perl

# Copyright (C) 2006-2007, The Parrot Foundation.
# $Id: cmd_upvar.t 21247 2007-09-13 06:31:01Z paultcochrane $

# the following lines re-execute this as a tcl script
# the \ at the end of these lines makes them a comment in tcl \
use lib qw(lib); # \
use Tcl::Test; #\
__DATA__

source lib/test_more.tcl
plan 12

eval_is {
 set a 2
 proc add3 var {
   upvar $var n
   set n [expr "3+$n"]
 }
 add3 a
 set a
} 5 {upvar $var n}

eval_is {
  upvar 0 a b
  set a 1
  set b
} 1 {upvar as alias in global scope}

eval_is {
  proc test {} {
    set b 1
    upvar 0 a b
  }
  test
} {variable "b" already exists} \
  {variable already exists}

eval_is {
  catch {unset a}
  upvar 0 a(b) c
  array set a [list b 3]
  set c
} 3 {upvar into an array}

eval_is {
  array set a [list 1 2 3 4]
  upvar 0 a b
  array get b 1
} {1 2} {upvar with array}

eval_is {
  proc add2 {varName} {upvar $varName var; set var [expr {$var+2}]}
  proc test {} { set a 1; add2 a; return $a }
  test
} 3 {upvar from one lexpad to another}

eval_is {upvar} \
  {wrong # args: should be "upvar ?level? otherVar localVar ?otherVar localVar ...?"} \
  {upvar no args}

eval_is {upvar 1} \
  {wrong # args: should be "upvar ?level? otherVar localVar ?otherVar localVar ...?"} \
  {upvar one args}

# can't use 'test' here because of the proc level, so roll our own eval.
is [catch {upvar a b} var; set var] {bad level "a"} {bad level}

eval_is {
  proc test {} {upvar 3 a b}
  test
} {bad level "3"} \
  {can't go higher than the top level}

eval_is {
  upvar -1 a b
} {bad level "-1"} \
  {no negative level}

eval_is {
  namespace eval test {
    set x ok
    upvar 0 x y
  }
  set test::y
} ok {upvar + namespace eval}
