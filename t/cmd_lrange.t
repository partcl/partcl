#!perl

# Copyright (C) 2006, The Parrot Foundation.

# the following lines re-execute this as a tcl script
# the \ at the end of these lines makes them a comment in tcl \
use lib qw(lib); # \
use Tcl::Test; #\
__DATA__

source lib/test_more.tcl
plan 6

eval_is {lrange list 1} \
  {wrong # args: should be "lrange list first last"} \
  {too few args}

eval_is {lrange list 1 2 3} \
  {wrong # args: should be "lrange list first last"} \
  {too many args}

is [lrange [list 0 1 2 3 4 5] 2 23] {2 3 4 5} \
  {last is greater than the elements in the list}

is [lrange [list 0 1 2 3 4 5] -43 2] {0 1 2} \
  {first is negative}

is [lrange {0 1 2 3 4 5} 3 end-1] {3 4} \
  {end-1 as an index}

is [lrange {0 1 2} 3 2] {} {first > last}
