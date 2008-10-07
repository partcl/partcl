#!perl

# Copyright (C) 2004-2006, The Perl Foundation.
# $Id: cmd_unset.t 26434 2008-03-17 01:01:32Z coke $

# the following lines re-execute this as a tcl script
# the \ at the end of these lines makes them a comment in tcl \
use lib qw(languages/tcl/lib tcl/lib lib ../lib ../../lib); # \
use Tcl::Test; #\
__DATA__

source lib/test_more.tcl
plan 21

eval_is {unset a} \
  {can't unset "a": no such variable} \
  {unset nothing}

eval_is {
 set a 2
 unset a
} {} {unset something}

eval_is {
 set a 2
 unset a
 set a
} {can't read "a": no such variable} \
  {unset something, use it again}

eval_is {
 set a(2) 2
 unset a(2)
 puts $a(2)
} {can't read "a(2)": no such element in array} \
  {set/unset array element}

eval_is {
 set b(2) 2
 unset b
 set b(2)
} {can't read "b(2)": no such variable} \
  {set/unset array}

eval_is {
 set c(1) 1
 unset c(2)
} {can't unset "c(2)": no such element in array} \
  {unset missing array element}

eval_is {unset d(2)} \
  {can't unset "d(2)": no such variable} \
  {unset element in missing array}

is [unset] {} {unset - no args}

eval_is {
 set -nocomplain 2
 unset -nocomplain
 set -nocomplain
} 2 {unset -nocomplain}

eval_is {
 set -nocomplain 2
 unset -nocomplain -nocomplain
 set -nocomplain
} {can't read "-nocomplain": no such variable} \
  {unset -nocomplain -nocomplain}

eval_is {unset -nocomplain foo} {} {unset -nocomplain foo}

eval_is {
  set -- 2
  unset -nocomplain -- foo
  set --
} 2 {unset -nocomplain -- foo}

eval_is {
  set foo 2
  set bar 3
  unset foo bar
  list [catch {puts $foo}] [catch {puts $bar}]
} {1 1} {unset multiple variables}

eval_is {
  catch {unset a}
  set a [list 1 2 3 4]
  unset a
  set a
} {can't read "a": no such variable} \
  {unset list}

eval_is {
  catch {unset a}
  set a 1
  upvar 0 a b
  unset b
  set a
} {can't read "a": no such variable} \
  {unset upvar}

eval_is {
  catch {unset a}
  proc test {} {global a; unset a}
  set a 1
  test
  set a
} {can't read "a": no such variable} \
  {unset global}

eval_is {
  catch {unset a}
  set a 1
  upvar 0 a b
  unset b
  set b 2
  set a
} 2 {reset an unset upvar}

eval_is {
  catch {unset array}
  array set array {a 1 b 2}
  upvar 0 array(a) elem
  unset elem
  set elem 7
  set array(a)
} 7 {reset an unset array elem upvar}

eval_is {
  catch {unset array}
  array set array {a 1 b 2}
  upvar 0 array(a) elem
  unset elem
  set array(a)
} {can't read "array(a)": no such element in array} \
  {unset array elem upvar} {TODO {used to work!}}

eval_is {
  catch {unset array}
  upvar 0 array(b) c
  set c 4
  unset array(b)
  set c
} {variable "c" already exists} \
  {unset an aliased array elem} {TODO {not fixed yet}}

eval_is {
  catch {unset a}
  set a 55
  unset a(f)
} {can't unset "a(f)": variable isn't array} \
  {variable isn't array}
