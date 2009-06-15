#!perl

# the following lines re-execute this as a tcl script
# the \ at the end of these lines makes them a comment in tcl \
use lib qw(lib); # \
use Tcl::Test; #\
__DATA__

source lib/test_more.tcl

plan 2

is [lreverse {r a y e}]  {e y a r} {simple lreverse, even # of elements}
is [lreverse {c h i e f}]  {f e i h c} {simple lreverse, odd # of elements}

