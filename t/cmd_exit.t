#!perl

# Copyright (C) 2004-2006, The Parrot Foundation.
# $Id: cmd_exit.t 21247 2007-09-13 06:31:01Z paultcochrane $

use strict;
use warnings;
use lib qw(lib);

use Parrot::Test::Tcl;
use Test::More tests => 3;

tcl_output_is( <<'TCL', <<OUT, "noarg" );
 puts here
 exit
 puts nothere
TCL
here
OUT

tcl_output_is( <<'TCL', <<OUT, "bad arg" );
 exit bork
TCL
expected integer but got "bork"
OUT

tcl_output_is( <<'TCL', <<OUT, "too many args" );
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
