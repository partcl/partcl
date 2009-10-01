#!perl

# Copyright (C) 2004-2007, The Parrot Foundation.
# $Id: cmd_rename.t 26313 2008-03-11 14:43:47Z coke $

use strict;
use warnings;
use lib qw(lib);

use Parrot::Test::Tcl;
use Test::More tests=> 9;

tcl_output_is( <<'TCL', <<OUT, "rename" );
 set a 2
 rename puts fnord
 fnord $a
TCL
2
OUT

tcl_output_is( <<'TCL', <<OUT, "remove" );
 rename puts ""
 puts "Whee"
TCL
invalid command name "puts"
OUT

tcl_output_is( <<'TCL', <<'OUT', "rename non-existant command" );
 rename foo blah
TCL
can't rename "foo": command doesn't exist
OUT

tcl_output_is( <<'TCL', <<'OUT', "delete non-existant command" );
 rename foo ""
TCL
can't delete "foo": command doesn't exist
OUT

tcl_output_is( <<'TCL', <<'OUT', 'new command already exists' );
  rename if incr
TCL
can't rename to "incr": command already exists
OUT

tcl_output_is( <<'TCL', <<'OUT', "test fallback to interpreted versions of normally inlined commands." );
 set a 1
 incr a
 rename if {}
 incr a
 puts $a
TCL
3
OUT

tcl_output_is( <<'TCL', <<'OUT', "delete inlined sub", todo => "failing after switch to tcl's [unknown]");
 set a 1
 incr a
 puts $a
 rename incr {}
 incr a
TCL
2
invalid command name "incr"
OUT

tcl_output_is( <<'TCL', <<'OUT', "rename inlined sub" );
 set a 1
 rename incr foo
 foo a
 puts $a
TCL
2
OUT

tcl_output_is( <<'TCL', <<'OUT', "rename in a namespace" );
proc puts2 {args} {puts {*}$args}

namespace eval joe {
    proc puts2 {args} {puts "HELLO WORLD"}
}

namespace eval joe {
    puts2 "HI THERE"
    rename puts2 {}
}

puts2 "HI THERE"

namespace eval joe {
    puts "HI THERE"
}
TCL
HELLO WORLD
HI THERE
HI THERE
OUT

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
