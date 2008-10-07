#!perl

# Copyright (C) 2004-2006, The Perl Foundation.
# $Id: cmd_for.t 21247 2007-09-13 06:31:01Z paultcochrane $

# the following lines re-execute this as a tcl script
# the \ at the end of these lines makes them a comment in tcl \
use lib qw(languages/tcl/lib tcl/lib lib ../lib ../../lib); # \
use Tcl::Test; #\
__DATA__

source lib/test_more.tcl
plan 10

eval_is {
 set r ""
 for {set a 0} {$a < 5} {incr a} {
   set r [append r $a]
 }
 set r
} 01234 {simple for}

eval_is {
 set r ""
 set a {set r [append r $i]}
 for {set i 0} {$i < 5} {set i [expr $i+1]} $a
 set r
} 01234 {variable for last arg}

eval_is {
  set r ""
  for {set x 11} {$x < 10} {incr x} {set r [append r $x]}
  set r
} {} {test not met initially}

is [for {set i 1} {$i < 4} {incr i} {}] {} \
  {[for] returns ''}

eval_is {for {} {"foo"} {} {}} \
  {expected boolean value but got "foo"} \
  {boolean test}

eval_is {for} \
  {wrong # args: should be "for start test next command"} \
  {no args}

eval_is {for pete's} \
  {wrong # args: should be "for start test next command"} \
  {one args}

eval_is {for pete's sake} \
  {wrong # args: should be "for start test next command"} \
  {two args}

eval_is {for pete's sake don't} \
  {wrong # args: should be "for start test next command"} \
  {three args}

eval_is {for pete's sake don't do that.} \
  {wrong # args: should be "for start test next command"} \
  {too many args}

