#!perl

# Copyright (C) 2006, The Parrot Foundation.

# the following lines re-execute this as a tcl script
# the \ at the end of these lines makes them a comment in tcl \
use lib qw(lib); # \
use Tcl::Test; #\
__DATA__

source lib/test_more.tcl
plan 2

set some_var 3

proc tracer {args} {
  global some_var
  set some_var x
}

set a(1) 2
trace variable a r tracer
set a(1) 3
is $a(1) 3 {set should still work}
is $some_var x {trigger should have hit}
