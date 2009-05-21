#!perl

# Copyright (C) 2004-2008, The Perl Foundation.
# $Id: cmd_foreach.t 29812 2008-07-28 00:44:19Z coke $

# the following lines re-execute this as a tcl script
# the \ at the end of these lines makes them a comment in tcl \
use lib qw(lib); #\
use Tcl::Test; #\
__DATA__

source lib/test_more.tcl
plan 16

eval_is {foreach} \
  {wrong # args: should be "foreach varList list ?varList list ...? command"} \
  {no args}

eval_is {foreach a b q {puts $a}} \
  {wrong # args: should be "foreach varList list ?varList list ...? command"} \
  {uneven # of args}

eval_is {foreach {} {a b c} {puts foo}} \
  {foreach varlist is empty} \
  {empty varList}

eval_is {
    array set a {}
    foreach a {1 2 3 4} {puts $a}
} {can't set "a": variable is array} \
  {couldn't set loop variable}

unset -nocomplain a
is [foreach a {1 2 3 4} {set a}] {} {return value}

eval_is {
  set r ""
  foreach a {a b c} {append r $a}
  set r
} {abc} {single var/list}

eval_is {
  set r ""
  foreach a {a b c} b {d e f} {append r "$a $b:"}
  set r
} {a d:b e:c f:} {double var/list}

eval_is {
  set r ""
  foreach a {a b c} b {d e f g h} {append r "$a $b:"}
  set r
} {a d:b e:c f: g: h:} {double var/list, uneven}

eval_is {
  set r ""
  foreach a [list a b c] {append r $a}
  set r
} {abc} {single var/list, list object}

eval_is {
  set r ""
  foreach a [list a b c] b [list d e f] {append r "$a $b:"}
  set r
} {a d:b e:c f:} {double var/list, list objects}

eval_is {
  set r ""
  foreach a [list a b c] {append r $a; break}
  set r
} a {break}

eval_is {
  set r ""
  foreach a [list 1 2 3] {if {$a <2} {continue} ; append r $a}
  set r
} 23 {continue}

eval_is {
  proc test {} {
      set r ""
      foreach name {a b c d} {
          append r $name
      }
      return $r
  }
  test
} abcd {lexicals}

eval_is {
  foreach name {a b c d} { aputs }
} {invalid command name "aputs"} {inner exception}

is [
    set x {}
    foreach {c n} {a 1 b 2 c} {append x "$c = $n;"}
    set x
] {a = 1;b = 2;c = ;} \
  {multiple index variables}

eval_is {
  namespace eval lib {
    set val {}
    proc a {} {error ok}
    foreach n 1 a
  }
} ok {namespace resolution in body}
