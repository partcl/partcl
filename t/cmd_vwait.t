#!perl

# Copyright (C) 2006-2007, The Perl Foundation.
# $Id: cmd_vwait.t 21247 2007-09-13 06:31:01Z paultcochrane $

# the following lines re-execute this as a tcl script
# the \ at the end of these lines makes them a comment in tcl \
use lib qw(lib); # \
use Tcl::Test; #\
__DATA__

source lib/test_more.tcl

plan 2

eval_is {vwait} \
  {wrong # args: should be "vwait name"} \
  {too few args}

eval_is {vwait foo bar} \
  {wrong # args: should be "vwait name"} \
  {too many args}
