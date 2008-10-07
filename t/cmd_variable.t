#!perl

# Copyright (C) 2006-2007, The Perl Foundation.
# $Id: cmd_variable.t 31354 2008-09-23 01:11:49Z coke $

# the following lines re-execute this as a tcl script
# the \ at the end of these lines makes them a comment in tcl \
use lib qw(languages/tcl/lib tcl/lib lib ../lib ../../lib); # \
use Tcl::Test; #\
__DATA__

source lib/test_more.tcl

plan 9

eval_is {
  variable
} {wrong # args: should be "variable ?name value...? name ?value?"} \
  {bad args}

eval_is {variable foo} {} {variable's return value}

eval_is {
  catch {unset foo}
  catch {unset bar}
  variable foo 3 bar 5
  list $foo $bar
} {3 5} {variable foo 3 bar 5}

eval_is {
  catch {unset foo}
  variable foo
  set foo
} {can't read "foo": no such variable} \
  {variable foo}

eval_is {
  catch {unset foo}
  catch {unset bar}
  variable foo 3 bar
  list $foo [catch {set bar} msg] $msg
} {3 1 {can't read "bar": no such variable}} \
  {variable foo 3 bar}

eval_is {variable foo(bar)} \
  {can't define "foo(bar)": name refers to an element in an array} \
  {variable with array}

eval_is {
  variable foo( 4 foo) 4 foo(bar)baz 4
  list [set foo(] [set foo)] [set foo(bar)baz]
} {4 4 4} \
  {these aren't arrays - they should work}

eval_is {
  proc test {} {
    variable x 5
    set x
  }
  list [test] [set x]
} {5 5} {variable is always about globals}

namespace eval lib {
  variable foo 7
}
proc ::lib::test {} {
  variable foo
  set foo
}
eval_is {::lib::test} 7 {variable using current namespace}
