#!perl

# Copyright (C) 2006-2007, The Perl Foundation.
# $Id: cmd_split.t 21247 2007-09-13 06:31:01Z paultcochrane $

# the following lines re-execute this as a tcl script
# the \ at the end of these lines makes them a comment in tcl \
use lib qw(languages/tcl/lib tcl/lib lib ../lib ../../lib); # \
use Tcl::Test; #\
__DATA__

source lib/test_more.tcl
plan 7

eval_is {split}  \
  {wrong # args: should be "split string ?splitChars?"} \
  {split too few args}

eval_is {split a b c}  \
  {wrong # args: should be "split string ?splitChars?"} \
  {split too many args}

is [lindex [split {that is fun}] 2] fun {split default}

is [split {Modern Major General} {}] \
  {M o d e r n { } M a j o r { } G e n e r a l} \
  {split empty string}

is [split {perl.perl6.language} .] \
  {perl perl6 language} {split single char}

is [split {perl.perl6.language} glop] \
  {{} er . er 6. an ua e} {split multi char}

is [split {perl.perl6.language} z] {perl.perl6.language} {split and a miss}
