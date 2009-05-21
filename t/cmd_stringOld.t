#!perl

# Copyright (C) 2004-2007, The Perl Foundation.
# $Id: cmd_stringOld.t 21247 2007-09-13 06:31:01Z paultcochrane $

use strict;
use warnings;
use lib qw(lib);

use Parrot::Test::Tcl;

use Parrot::Installed;
use Parrot::Config;
use Test::More tests => 5;

SKIP: {
    skip( "Parrot not configured with ICU", 5 ) unless $PConfig{has_icu};
    tcl_output_is( <<TCL, <<OUT, "string match nocase" );
  puts [string match -nocase ABC abc]
TCL
1
OUT

    tcl_output_is( <<'TCL', <<OUT, "string match nocase: unicode (Greek alphas)" );
  puts [string match -nocase \u03b1 \u0391]
TCL
1
OUT

    tcl_output_is( <<'TCL', <<OUT, "string equal, diff with -nocase" );
  puts [string equal -nocase APPLEs oranGES]
TCL
0
OUT

    tcl_output_is( <<'TCL', <<OUT, "string equal, same with -nocase" );
  puts [string equal -nocase baNAna BAnana]
TCL
1
OUT

    tcl_output_is( <<'TCL', <<OUT, "string equal, -length and -nocase" );
  puts [string equal -nocase -length 4 fERry FeRroUs]
TCL
1
OUT
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
