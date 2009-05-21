#!perl

# Copyright (C) 2004-2006, The Perl Foundation.
# $Id: cmd_source.t 21247 2007-09-13 06:31:01Z paultcochrane $

use strict;
use warnings;
use lib qw(lib);

use Parrot::Installed;
use Parrot::Test tests => 2;
use Test::More;

# prolly not portable, patches welcome.
my $source_filename = 'tmp.tcl';
open( my $tmpfile, '>', $source_filename ) or die $!;
print {$tmpfile} <<'EOF';
 set a 10
 puts $b
EOF
close $tmpfile;

language_output_is( "tcl", <<TCL, <<OUT, "simple source" );
 set b 20
 source "$source_filename"
 puts \$a
TCL
20
10
OUT

# clean up temp file.
unlink($source_filename);

language_output_is( "tcl", <<'TCL', <<'OUT', "invalid file" );
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
