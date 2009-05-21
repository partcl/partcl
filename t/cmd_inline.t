#!perl

# Copyright (C) 2005-2006, The Perl Foundation.
# $Id: cmd_inline.t 27335 2008-05-06 05:49:04Z coke $

use strict;
use warnings;
use lib qw(lib);

use Parrot::Test::Tcl;
use Test::More tests => 4;

tcl_output_is( <<'TCL', <<'OUT', "PIR compiler" );
 inline PIR {
   .sub test
     print "ok\n"
   .end 
 }
TCL
ok
OUT

tcl_output_is( <<'TCL', <<'OUT', "PASM compiler" );
 inline PASM {
   print "ok\n"
   end
 }
TCL
ok
OUT

tcl_output_is( <<'TCL', <<'OUT', "invalid compiler" );
 inline JAVA {
   System.out.println("mmm, coffee");
 }
TCL
invalid language "JAVA" specified
OUT

tcl_output_is( <<'TCL', <<'OUT', "invalid PIR code" );
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
