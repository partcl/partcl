package Tcl::Test;

# Copyright (C) 2006-2007, The Perl Foundation.
# $Id: Test.pm 29432 2008-07-14 14:38:24Z coke $

use warnings;
use strict;

use lib qw(lib);

use Parrot::Installed;
use Parrot::Config;
use File::Spec;

sub import {
    my $parrot = $PConfig{bindir} . "/" . $PConfig{test_prog} . $PConfig{exe};
    my $test = File::Spec->rel2abs($0);

    if ( exists $ENV{TEST_PROG_ARGS} ) {
        exec $parrot, $ENV{TEST_PROG_ARGS}, 'tcl.pbc', $test;
    }
    else
    {
        exec $parrot, 'tcl.pbc', $test;
    }
}
1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
