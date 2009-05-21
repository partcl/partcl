#!perl

# Copyright (C) 2004-2007, The Perl Foundation.
# $Id: cmd_catch.t 31351 2008-09-22 21:14:32Z coke $

# the following lines re-execute this as a tcl script
# the \ at the end of these lines makes them a comment in tcl \
use lib qw(lib); # \
use Tcl::Test; #\
__DATA__

source lib/test_more.tcl
plan 12

eval_is {
  catch {
    error dead
  }
  set a ""
} {} {discard error}

eval_is {
  catch {
    error dead
  } var
  set var
} {dead} {error messsage}

eval_is {
  catch {
    set b 0
  }
} 0 {error type: none}

eval_is {
  catch {
    error dead
  }
} 1 {error type: error}

eval_is {
  catch {
    return
  }
} 2 {error type: return}

eval_is {
  catch {
    break
  }
} 3 {error type: break}

eval_is {
  catch {
    continue
  }
} 4 {error type: continue}

eval_is {
  set a [catch blorg var]
  list $a $var
} {1 {invalid command name "blorg"}} {error, invalid command}

eval_is {catch} \
  {wrong # args: should be "catch script ?resultVarName? ?optionVarName?"} \
  {too few args}

eval_is {
  list [catch {incr} msg] $msg
} {1 {wrong # args: should be "incr varName ?increment?"}} \
  {catch {incr} msg}

eval_is {
  namespace eval abc {
    proc a {} {return "ok"}
    proc b {} {catch {a} msg; return $msg }
    b
  }
} ok {catch should respect the namespace it is invoked in}

eval_is {
  set a 3
  catch {
    set a 2
    set a [
  }
  set a
} 2 {execute code as soon as possible, don't wait until the end of the block} \
{TODO {Still trying to compile the whole block first.}}
