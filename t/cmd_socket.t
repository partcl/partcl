#!perl

# Copyright (C) 2006-2007, The Perl Foundation.
# $Id: cmd_socket.t 21247 2007-09-13 06:31:01Z paultcochrane $

# the following lines re-execute this as a tcl script
# the \ at the end of these lines makes them a comment in tcl \
use lib qw(lib); # \
use Tcl::Test; #\
__DATA__

source lib/test_more.tcl

plan 3

eval_is {socket host} \
  {wrong # args: should be "socket ?-myaddr addr? ?-myport myport? ?-async? host port" or "socket -server command ?-myaddr addr? port"} \
  {too few args}

eval_is {socket host port foo} \
  {wrong # args: should be "socket ?-myaddr addr? ?-myport myport? ?-async? host port" or "socket -server command ?-myaddr addr? port"} \
  {too many args}

set SKIP {SKIP "awaiting socket implementation"}

eval_is {socket a 80} \
  {couldn't open socket: host is unreachable} \
  {unreachable host} \
  $SKIP
