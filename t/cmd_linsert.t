#!perl

# Copyright (C) 2004-2006, The Perl Foundation.
# $Id: cmd_linsert.t 21247 2007-09-13 06:31:01Z paultcochrane $

# the following lines re-execute this as a tcl script
# the \ at the end of these lines makes them a comment in tcl \
use lib qw(languages/tcl/lib tcl/lib lib ../lib ../../lib); # \
use Tcl::Test; #\
__DATA__

source lib/test_more.tcl
plan 10

is [linsert [list] 0 a]  a {insert beginning empty list}
is [linsert [list] 20 a] a {insert beyond end of empty list}
is [linsert [list a] end b] {a b} {insert beyond end of single list}
is [linsert [list a c] end-1 b] {a b c} {insert middle double list}

is [linsert list 0 new] {new list} {insert at beginning of list}

is [linsert [list a b] end [list c d]] {a b {c d}} {insert, sub list}
is [linsert [list a b] end c d] {a b c d} {insert, multiple elements}

eval_is {linsert} \
  {wrong # args: should be "linsert list index element ?element ...?"} \
  {too few args}

eval_is {linsert a} \
  {wrong # args: should be "linsert list index element ?element ...?"} \
  {too few args}

eval_is {
  linsert [list a c] q b]
} {bad index "q": must be integer?[+-]integer? or end?[+-]integer?} \
  {insert bad index}

