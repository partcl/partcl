#!perl

# Copyright (C) 2004-2006, The Parrot Foundation.

use strict;
use warnings;
use lib qw(lib);

use Parrot::Test::Tcl;
use Test::More tests => 5;

# RT#40618:  Missing channelId tests.

tcl_output_is( <<'TCL', <<OUT, "no args" );
 puts
TCL
wrong # args: should be "puts ?-nonewline? ?channelId? string"
OUT

tcl_output_is( <<'TCL', <<OUT, "too many args" );
 puts a b c d
TCL
wrong # args: should be "puts ?-nonewline? ?channelId? string"
OUT

tcl_output_is( <<'TCL', <<OUT, "-nonewline" );
  puts -nonewline whee\n
TCL
whee
OUT

tcl_output_is( <<'TCL', <<OUT, "normal" );
 puts whee
TCL
whee
OUT

tcl_output_is( <<'TCL', <<'OUT', "puts stdout ok" );
  puts stdout ok
TCL
ok
OUT

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
