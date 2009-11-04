#!perl

# Copyright (C) 2004-2006, The Parrot Foundation.

# the following lines re-execute this as a tcl script
# the \ at the end of these lines makes them a comment in tcl \
use lib qw(lib); #\
use Tcl::Test; #\
__DATA__

source lib/test_more.tcl
plan 3

eval_is {format} \
  {wrong # args: should be "format formatString ?arg arg ...?"} \
  {format no args}

is [format "%05d" 12]              00012              {zero padding}
is [format "%-*s - %s" 10 foo bar] {foo        - bar} {format width check}
