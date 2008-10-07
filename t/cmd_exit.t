#!perl

# Copyright (C) 2004-2006, The Perl Foundation.
# $Id: cmd_exit.t 21247 2007-09-13 06:31:01Z paultcochrane $

use strict;
use warnings;
use lib qw(tcl/lib ./lib ../lib ../../lib ../../../lib);

use Parrot::Test tests => 3;
use Test::More;

language_output_is( "tcl", <<'TCL', <<OUT, "noarg" );
 puts here
 exit
 puts nothere
TCL
here
OUT

language_output_is( "tcl", <<'TCL', <<OUT, "bad arg" );
 exit bork
TCL
expected integer but got "bork"
OUT

language_output_is( "tcl", <<'TCL', <<OUT, "too many args" );
 exit bork me
TCL
wrong # args: should be "exit ?returnCode?"
OUT

# (RT#40777): should check return value of exit, also

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
