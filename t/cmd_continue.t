#!perl

# Copyright (C) 2004-2006, The Perl Foundation.
# $Id: cmd_continue.t 21247 2007-09-13 06:31:01Z paultcochrane $

# the following lines re-execute this as a tcl script
# the \ at the end of these lines makes them a comment in tcl \
use lib qw(languages/tcl/lib tcl/lib lib ../lib ../../lib); # \
use Tcl::Test; #\
__DATA__

source lib/test_more.tcl
plan 4

eval_is {
 set result ""
 for {set a 0} {$a < 10} {incr a} {
   if {$a > 5} { continue }
   set result [append result $a]
 }
 list $a $result
} {10 012345} {continue from for}

eval_is {
 set result ""
 set a 0
 while {$a <= 10} {
   incr a
   if {$a < 5} { continue }
   set result [append result $a]
 }
 list $a $result
} {11 567891011} {continue from while}

eval_is {
  proc test {} {continue}
  test
} {invoked "continue" outside of a loop} \
  {continue outside of a loop}

eval_is {
  proc test {} {continue}
  for {set i 0} {$i < 5} {incr i} {test}
} {invoked "continue" outside of a loop} \
  {continue in a proc called in a loop}
