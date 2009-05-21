#!perl

# Copyright (C) 2005-2006, The Perl Foundation.
# $Id: cmd_inline.t 27335 2008-05-06 05:49:04Z coke $

use strict;
use warnings;
use lib qw(lib);

use Parrot::Installed;
use Parrot::Test tests => 4;
use Test::More;

language_output_is( "tcl", <<'TCL', <<'OUT', "PIR compiler" );
 inline PIR {
   .sub test
     print "ok\n"
   .end 
 }
TCL
ok
OUT

language_output_is( "tcl", <<'TCL', <<'OUT', "PASM compiler" );
 inline PASM {
   print "ok\n"
   end
 }
TCL
ok
OUT

language_output_is( "tcl", <<'TCL', <<'OUT', "invalid compiler" );
 inline JAVA {
   System.out.println("mmm, coffee");
 }
TCL
invalid language "JAVA" specified
OUT

language_output_is( "tcl", <<'TCL', <<'OUT', "invalid PIR code" );
catch {
 inline PIR {
   .sub test
     say "not ok
   .end 
 }
} err
puts "ok"
TCL
ok
OUT

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
