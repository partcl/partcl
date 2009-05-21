#!perl

# Copyright (C) 2006, The Perl Foundation.
# $Id: cmd_cd.t 26334 2008-03-12 17:34:46Z particle $

use strict;
use warnings;
use lib qw(lib);

use Parrot::Installed;
use Parrot::Test tests => 3;
use Test::More;
use File::Temp qw(tempdir);
use File::Spec;
use Cwd qw(abs_path);

language_output_is( "tcl", <<'TCL', <<OUT, "cd too many args" );
 cd a b
TCL
wrong # args: should be "cd ?dirName?"
OUT

## tclsh on windows shows unix slashies, so use unix canonpath to get them
my $homedir = File::Spec::Unix->canonpath( $ENV{HOME} );

TODO: {
    local $TODO;
    $TODO = 'pwd is broken on windows' if $^O eq 'MSWin32';

    language_output_is( "tcl", <<'TCL', <<"OUT", "cd home" );
 cd
 puts [pwd]
TCL
$homedir
OUT
}

{
    my $testdir = tempdir( CLEANUP => 1 );
    my $expdir = File::Spec->canonpath( abs_path($testdir) );
    $^O eq 'MSWin32' and $testdir =~ s/\\/\\\\/g;
    language_output_is( "tcl", <<"TCL", <<"OUT", "cd home" );
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
