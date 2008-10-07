#!perl

# Copyright (C) 2004-2006, The Perl Foundation.
# $Id: cmd_break.t 21247 2007-09-13 06:31:01Z paultcochrane $

# the following lines re-execute this as a tcl script
# the \ at the end of these lines makes them a comment in tcl \
use lib qw(languages/tcl/lib tcl/lib lib ../lib ../../lib); # \
use Tcl::Test; #\
__DATA__

source lib/test_more.tcl

plan 4

eval_is {
 for {set a 0} {$a < 20} {incr a} {
   if {$a > 10} { break }
 }
 set a
} 11 {break from for}

eval_is {
 set a 20
 while {$a} {
   incr a -1
   if {$a < 10} { break }
 }
 set a
} 9 {break from while}

eval_is {
  proc test {} {break}
  test
} {invoked "break" outside of a loop} \
  {break outside of a loop}

eval_is {
  proc test {} {break}
  for {set i 0} {$i < 5} {incr i} {test}
} {invoked "break" outside of a loop} \
  {break in a proc called in a loop}
