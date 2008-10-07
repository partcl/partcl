#!perl

# Copyright (C) 2004-2006, The Perl Foundation.
# $Id: cmd_puts.t 21247 2007-09-13 06:31:01Z paultcochrane $

use strict;
use warnings;
use lib qw(tcl/lib ./lib ../lib ../../lib ../../../lib);

use Parrot::Test tests => 5;
use Test::More;

# RT#40618:  Missing channelId tests.

language_output_is( "tcl", <<'TCL', <<OUT, "no args" );
 puts
TCL
wrong # args: should be "puts ?-nonewline? ?channelId? string"
OUT

language_output_is( "tcl", <<'TCL', <<OUT, "too many args" );
 puts a b c d
TCL
wrong # args: should be "puts ?-nonewline? ?channelId? string"
OUT

language_output_is( "tcl", <<'TCL', <<OUT, "-nonewline" );
  puts -nonewline whee\n
TCL
whee
OUT

language_output_is( "tcl", <<'TCL', <<OUT, "normal" );
 puts whee
TCL
whee
OUT

language_output_is( "tcl", <<'TCL', <<'OUT', "puts stdout ok" );
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
