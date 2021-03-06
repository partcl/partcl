#! perl

# Copyright (C) 2004-2007, The Parrot Foundation.

use strict;
use warnings;
use lib qw(lib);

use Parrot::Test::Tcl;
use Test::More tests => 1;

{
    $ENV{cow}    = 'moo';
    $ENV{pig}    = 'oink';
    $ENV{cowpig} = 'moink';

    tcl_output_is( <<'TCL', <<"OUT", "reading environment variables" );
  puts "$env(cow) $env(pig) $env(cowpig)"
TCL
moo oink moink
OUT
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
