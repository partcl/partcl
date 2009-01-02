#!perl

# Copyright (C) 2005-2007, The Perl Foundation.
# $Id: tcl_pir_compiler.t 23374 2007-12-02 17:50:32Z coke $

use strict;
use warnings;
use lib qw(tcl/lib ./lib ../lib ../../lib ../../../lib);

use Parrot::Test tests => 7;
use Test::More;

pir_output_is( <<'CODE', <<'OUTPUT', "test tcl compiler, verify double call works" );
  .sub main :main
     load_bytecode "languages/tcl/runtime/tcllib.pbc"
     .local pmc tcl_compiler,compiled_sub
     tcl_compiler = compreg "TCL"
     compiled_sub = tcl_compiler("puts {ok 1}")
     compiled_sub()
     compiled_sub = tcl_compiler("puts {ok 2}")
     compiled_sub()
  .end 
CODE
ok 1
ok 2
OUTPUT

pir_output_is( <<'CODE', <<'OUTPUT', "test tcl compiler global variable interop" );
.HLL 'Tcl'
.loadlib 'tcl_group'
  .sub main :main
     load_bytecode 'languages/tcl/runtime/tcllib.pbc'
     .local pmc tcl_compiler,compiled_sub
     $P1 = box 'ok 1' 
     store_global '$a', $P1
     tcl_compiler = compreg 'TCL'
     compiled_sub = tcl_compiler("puts $a")
     compiled_sub()
  .end 
CODE
ok 1
OUTPUT

pir_output_is( <<'CODE', <<'OUTPUT', "pass arguments to a tcl proc from PIR" );
.HLL 'Tcl'
.loadlib 'tcl_group'
.sub main :main

  load_bytecode 'languages/tcl/runtime/tcllib.pbc'

  $P0 = compreg 'TCL'
  $P1 = $P0('proc _tmp {a} {puts $a}')
  $P1()

  $P2 = find_global '&_tmp'

  $P2('hello')
.end
CODE
hello
OUTPUT

pir_output_is( <<'CODE', <<'OUTPUT', "invoke argless tcl proc from PIR" );
.sub _main :main
  load_bytecode "languages/tcl/runtime/tcllib.pbc"
  $S1 = 'proc hey {} { puts 11 }; hey; '
  $P1 = compreg 'TCL'
  $P0 = $P1($S1)
  $P0()
.end
CODE
11
OUTPUT

pir_output_is( <<'CODE', <<'OUTPUT', "Verify HLL autoboxing: Int" );
.HLL 'Tcl'
.loadlib 'tcl_group'
.sub _main :main
  $P1 = test()
  $S1 = typeof $P1
  say $S1
.end
.sub test
  .return (1)
.end
CODE
TclInt
OUTPUT

pir_output_is( <<'CODE', <<'OUTPUT', "Verify HLL autoboxing: String" );
.HLL 'Tcl'
.loadlib 'tcl_group'
.sub _main :main
  $P1 = test()
  $S1 = typeof $P1
  say $S1
.end
.sub test
  .return ("coke")
.end
CODE
TclString
OUTPUT

pir_output_is( <<'CODE', <<'OUTPUT', "Verify HLL autoboxing: Float" );
.HLL 'Tcl'
.loadlib 'tcl_group'
.sub _main :main
  $P1 = test()
  $S1 = typeof $P1
  say $S1
.end
.sub test
  .return (8.14)
.end
CODE
TclFloat
OUTPUT

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
