#!perl

# Copyright (C) 2004-2006, The Perl Foundation.
# $Id: cmd_join.t 21247 2007-09-13 06:31:01Z paultcochrane $

# the following lines re-execute this as a tcl script
# the \ at the end of these lines makes them a comment in tcl \
use lib qw(languages/tcl/lib tcl/lib lib ../lib ../../lib); # \
use Tcl::Test; #\
__DATA__

source lib/test_more.tcl

plan 7

eval_is {join} {wrong # args: should be "join list ?joinString?"} \
  {too few args}
eval_is {join 1 2 3} {wrong # args: should be "join list ?joinString?"} \
  {too many args}

is [join [list]]       {}      {join nothing}
is [join [list a]]     {a}     {join one}
is [join [list a b c]] {a b c} {join few}

is [join [list a b c] X]    {aXbXc}       {join with string}
is [join [list a b c] XXXX] {aXXXXbXXXXc} {join with long string}
