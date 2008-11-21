#! perl

# Copyright (C) 2003-2006, The Perl Foundation.
# $Id: gen_builtins.pl 29804 2008-07-27 18:57:09Z coke $

use strict;
use warnings;
use lib qw(lib);

my $static_dir  = 'runtime/builtin';

print <<EOH;
# This file automatically generated by $0.

EOH

# commands that are in Tcl's :: namespace directly
my @static_cmds = pir_cmds_in_dir($static_dir);

print <<'END_PIR';
.HLL 'tcl'
.loadlib 'tcl_group'
END_PIR

print "  .include 'languages/tcl/$static_dir/$_.pir'\n" for @static_cmds;

sub pir_cmds_in_dir {
    my ($dir) = @_;

    opendir( DIR, $dir );

    # only return pir files (and strip the extension)
    my @files = grep { s/\.pir$// } readdir(DIR);
    closedir(DIR);

    return @files;
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
