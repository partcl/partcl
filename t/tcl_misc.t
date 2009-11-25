#! perl

# Copyright (C) 2004-2007, The Parrot Foundation.

# the following lines re-execute this as a tcl script
# the \ at the end of these lines makes them a comment in tcl \
use lib qw(lib); # \
use Tcl::Test; #\
__DATA__

source lib/test_more.tcl
plan 33

eval_is {
  set a Parsing
} Parsing {leading spaces on commands ok}

is [set a "Parsing"] Parsing {double quoting words}
is [set a {Parsing}] Parsing {block quoting}
is [set a Parsing]   Parsing {bare words}

eval_is {
  set a #whee
} {#whee} {comment must start command}

eval_is {
  list
} {} {command with no args}

eval_is {
  list;
} {} {command with no args, semicolon}

eval_is {
  list ;
} {} {command with no args, space-semicolon}

is [set x $] $ {$ by itself isn't a var}

is [set x ";"] {;} {; doesn't end command in the middle of a string}

eval_is {
  set a 2
  a
} {invalid command name "a"} {variables can't be used as commands}

eval_is {
# commment
} {} {comments start lines}

eval_is {
#one

#two
} {} {comments with a blank line in between ok}

eval_is {
#one
#two
} {} {2 comments in a row ok}

eval_is {
  # comment
} {} {leading whitespace ok on comments}

eval_is {
 set a 2
 # comment ; set a 3
 set a
} 2 {comments end on newline, not ;}

eval_is {
  list "a"a
} {extra characters after close-quote} "extra characters after close-quote"

eval_is {
  set a [list "a"a]
} {extra characters after close-quote} "extra characters after close-quote in []"

eval_is {
  list {a}a
} {extra characters after close-brace} {extra characters after close-brace}

eval_is {
  set a [set b 1; set c 2]
} 2 {subcommands with semicolons}

eval_is {
  proc {} {} {return ok}
  {}
} ok {empty proc name ok.}

eval_is {
  proc lreverse {} { return ok }
  lreverse
} ok {arg checking in proc overriding a builtin}

eval_is {
  set x 0012
  list $x [incr x]
} {0012 11} {order of arguments with integer conversion}

eval_is {
  set value [list a b c]
  set value 2
  set value
} 2 {list value can be overridden by a string value}


eval_is {
  set var {a   b c}
  list [join [list {*}$var] ,] \
    [join [list {*}{a {b c} d}] ,]
} {a,b,c {a,b c,d}} {expand}

is [{*}{set a hi}] hi {*, simple command}
is [{*}{set a "hello world"}] "hello world" {*, quotes}
is [{*}"set a {goodbye}"] "goodbye" {*, block}
is [{*}[concat set b {{hello world}}]] "hello world" {*, subcommand with args}
is [{*}[concat set c] {hello world}] "hello world" {*, subcommand}
is [set d set; {*}"$d b {hello world}"] "hello world" {*, dynamic command}

eval_is {
proc Default {{verify {boom}}} {
    [$verify]
}
Default
} {invalid command name "boom"} {failure to find a dynamic command'}

set a 4; incr a
is [lindex $a 0] 5 {can we convert integers into lists?}
