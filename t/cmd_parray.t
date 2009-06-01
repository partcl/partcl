#!perl

# Copyright (C) 2005-2006, The Perl Foundation.
# $Id: cmd_parray.t 31349 2008-09-22 20:05:49Z coke $

use strict;
use warnings;
use lib qw(lib);

use Parrot::Test::Tcl;
use Test::More tests=>9;

# verify interaction with auto_load...
tcl_output_is( <<'TCL', <<OUT, "body not loaded by default" );
 info body ::parray
TCL
"::parray" isn't a procedure
OUT

tcl_output_is( <<'TCL', <<OUT, "body available after auto_load" );
 auto_load parray
 info body ::parray
 puts ok
TCL
ok
OUT

tcl_output_is( <<'TCL', <<OUT, "body available after auto_load of FQ name" );
 auto_load ::parray
 info body ::parray
 puts ok
TCL
ok
OUT

my @todo = (todo => 'without unknown, these need an explicit auto_load now');

tcl_output_is( <<'TCL', <<OUT, "no args", @todo);
 parray
TCL
wrong # args: should be "parray a ?pattern?"
OUT

tcl_output_is( <<'TCL', <<OUT, "too many args", @todo );
 parray a b c d
TCL
wrong # args: should be "parray a ?pattern?"
OUT

tcl_output_is( <<'TCL', <<OUT, "bad array", @todo );
  parray bad_array
TCL
"bad_array" isn't an array
OUT

tcl_output_is( <<'TCL', <<OUT, "bad array, with pattern", @todo );
  parray bad_array bork?
TCL
"bad_array" isn't an array
OUT

@todo = (todo => 'generating extra newline after output');
tcl_output_is( <<'TCL', <<OUT, "with pattern", @todo );
  array set a [list z always ab first coco last]
  parray a a*
TCL
a(ab) = first
OUT

tcl_output_is( <<'TCL', <<OUT, "normal usage", @todo );
  array set a [list z always ab first coco last]
  parray a
TCL
a(ab)   = first
a(coco) = last
a(z)    = always
OUT

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:

