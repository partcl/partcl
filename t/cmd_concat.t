#!perl

# Copyright (C) 2004-2006, The Parrot Foundation.

# the following lines re-execute this as a tcl script
# the \ at the end of these lines makes them a comment in tcl \
use lib qw(lib); #\
use Tcl::Test; #\
__DATA__

source lib/test_more.tcl
plan 6

is [concat] {} {concat nothing}
is [concat a] {a} {concat one thing}
is [concat a b] {a b} {concat two things}

is [concat a [list b]] {a b} {concat sub list of one}
is [concat a [list b c]] {a b c} {concat sub list of one}
is [concat a [list b c [list d e]]] {a b c {d e}} {concat sub sub list of one}
