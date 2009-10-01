#!perl

# Copyright (C) 2006, The Parrot Foundation.
# $Id: cmd_pwd.t 26334 2008-03-12 17:34:46Z particle $

use strict;
use warnings;
use lib qw(lib);

use Parrot::Test::Tcl;
use Test::More tests=>2;
use File::Spec;
use Cwd;

tcl_output_is( <<'TCL', <<OUT, "pwd too many args" );
 pwd fish
TCL
wrong # args: should be "pwd"
OUT

## tclsh on windows shows unix slashies, so use unix canonpath to get them
my $dir = File::Spec::Unix->canonpath( getcwd );

my $todo = 'pwd is broken on windows' if $^O eq 'MSWin32';

tcl_output_is( <<'TCL', <<"OUT", "pwd simple", todo => $todo );
 puts [pwd]
TCL
$dir
OUT

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
