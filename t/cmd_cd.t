#!perl

# Copyright (C) 2006, The Parrot Foundation.
# $Id: cmd_cd.t 26334 2008-03-12 17:34:46Z particle $

use strict;
use warnings;
use lib qw(lib);

use Parrot::Test::Tcl;
use Test::More tests=>3;
use File::Temp qw(tempdir);
use File::Spec;
use Cwd qw(abs_path);

tcl_output_is( <<'TCL', <<OUT, "cd too many args" );
 cd a b
TCL
wrong # args: should be "cd ?dirName?"
OUT

## tclsh on windows shows unix slashies, so use unix canonpath to get them
my $homedir = $ENV{HOME} || $ENV{HOMEPATH};
$homedir = File::Spec::Unix->canonpath( $homedir );


my $todo = 'pwd is broken on windows' if $^O eq 'MSWin32';

tcl_output_is( <<'TCL', <<"OUT", "cd home", todo => $todo );
 cd
 puts [pwd]
TCL
$homedir
OUT

{
    my $testdir = tempdir( CLEANUP => 1 );
    my $expdir = File::Spec->canonpath( abs_path($testdir) );
    $^O eq 'MSWin32' and $testdir =~ s/\\/\\\\/g;
    tcl_output_is( <<"TCL", <<"OUT", "cd home" );
 cd $testdir
 puts [pwd]
TCL
$expdir
OUT
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
