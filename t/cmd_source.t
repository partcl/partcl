#!perl

# Copyright (C) 2004-2006, The Parrot Foundation.

use strict;
use warnings;
use lib qw(lib);

use Parrot::Test::Tcl;
use Test::More tests => 2;

# prolly not portable, patches welcome.
my $source_filename = 'tmp.tcl';
open( my $tmpfile, '>', $source_filename ) or die $!;
print {$tmpfile} <<'EOF';
 set a 10
 puts $b
EOF
close $tmpfile;

tcl_output_is( <<TCL, <<OUT, "simple source" );
 set b 20
 source "$source_filename"
 puts \$a
TCL
20
10
OUT

# clean up temp file.
unlink($source_filename);

tcl_output_is( <<'TCL', <<'OUT', "invalid file" );
 source "hopefullynonexistantfile.tcl"
TCL
couldn't read file "hopefullynonexistantfile.tcl": no such file or directory
OUT

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
