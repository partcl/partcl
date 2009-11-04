#!perl

# Copyright (C) 2005-2007, The Parrot Foundation.

# the following lines re-execute this as a tcl script
# the \ at the end of these lines makes them a comment in tcl \
use lib qw(lib); #\
use Tcl::Test; #\
__DATA__

source lib/test_more.tcl

plan 29

    ok [string match {b?n*a} banana]
    ok [string match {b?n*a} bznza]
    ok [string match {b?n*a} bana]

not_ok [string match {b?n*a} bnan]

    ok [string match {b\?n*a} b?nana]
not_ok [string match {b\?n*a} banana]
    ok [string match {b?n\*a} ban*a]
not_ok [string match {b?n\*a} banana]

    ok [string match {?n?*} bnan]
    ok [string match {?n?*} ana]
not_ok [string match {?n?*} an]

# character classes

    ok [string match {[ab]*} apple] ""
    ok [string match {[ab]*} boot]  ""
    ok [string match {[ab]*} a]     ""

not_ok [string match {[ab]*} ring]  ""

    ok [string match {[0-9]} 0]     ""
    ok [string match {[0-9]} 5]     ""
    ok [string match {[0-9]} 9]     ""
not_ok [string match {[0-9]} a]     ""

not_ok [string match {[^d-f]} z]    ""
not_ok [string match {[^d-f]} c]    ""
not_ok [string match {[!d-f]} g]    ""
    ok [string match {[!d-f]} d]    ""
    ok [string match {[^d-f]} e]    ""
    ok [string match {[^d-f]} f]    ""

# braces should be literal

    ok [string match {{az,bz}} "{az,bz}"] ""
not_ok [string match {{az,bz}} "bz"]      ""
    ok [string match {[a-z]{5}} "b{5}"]   ""
not_ok [string match {[a-z]{5}} "bbbbb"]  ""
