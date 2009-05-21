#!perl

# Copyright (C) 2005-2008, The Perl Foundation.
# $Id: cmd_namespace.t 31398 2008-09-25 03:46:52Z coke $

# the following lines re-execute this as a tcl script
# the \ at the end of these lines makes them a comment in tcl \
use lib qw(lib); # \
use Tcl::Test; #\
__DATA__

source lib/test_more.tcl
plan 41

eval_is {namespace} \
  {wrong # args: should be "namespace subcommand ?arg ...?"} \
  {namespace: no args}

eval_is {namespace asdf} \
  {bad option "asdf": must be children, code, current, delete, ensemble, eval, exists, export, forget, import, inscope, origin, parent, path, qualifiers, tail, unknown, upvar, or which} \
  {namespace: bad subcommand}


eval_is {namespace children a b c} \
  {wrong # args: should be "namespace children ?name? ?pattern?"} \
  {namespace children: too many args}

eval_is {namespace children what?} \
  {namespace "what?" not found in "::"} \
  {namespace children: unknown namespace} \
  {TODO {new behavior in 8.5.1}}

is [namespace children]        {::tcl} {namespace children: no args}
is [namespace children ::]     {::tcl} {namespace children: ::}
is [namespace children :: *c*] {::tcl} {namespace children: matched pattern}
is [namespace children :: a]   {}    {namespace children: unmatched pattern}

namespace eval bob {}
namespace eval Bob {}
namespace eval audreyt { namespace eval Matt {} }

is [namespace children ::] {::audreyt ::Bob ::bob ::tcl} \
  {namespace children: ordering}
is [namespace children ::audreyt] ::audreyt::Matt  {namespace chlidren: nested}
is [namespace eval ::audreyt {namespace children}] ::audreyt::Matt \
  {namespace children in namespace eval}


eval_is {namespace qualifiers} \
  {wrong # args: should be "namespace qualifiers string"} \
  {namespace qualifiers: no args}

eval_is {namespace qualifiers string string} \
  {wrong # args: should be "namespace qualifiers string"} \
  {namespace qualifiers: too many args}

is [namespace qualifiers ::a::b::c]   ::a::b   {namespace qualifiers: simple}
is [namespace qualifiers :::a:::b::c] :::a:::b {namespace qualifiers: extra colons}


eval_is {namespace tail} \
  {wrong # args: should be "namespace tail string"} \
  {namespace tail: no args}

eval_is {namespace tail string string} \
  {wrong # args: should be "namespace tail string"} \
  {namespace tail: too many args}

is [namespace tail ::a::b::c]   c {namespace tail: simple}
is [namespace tail :::a:::b::c] c {namespace tail: extra colons}


eval_is {namespace exists} \
  {wrong # args: should be "namespace exists name"} \
  {namespace exists: no args}

eval_is {namespace exists a a} \
  {wrong # args: should be "namespace exists name"} \
  {namespace exists: too many args}

eval_is {namespace exists a}  0 {namespace exists: failure} {TODO {broken in r30286}}
is [namespace exists {}] 1 {namespace exists: global implicit}
is [namespace exists ::] 1 {namespace exists: global explicit}


eval_is {namespace eval foo} \
  {wrong # args: should be "namespace eval name arg ?arg...?"} \
  {namespace eval: too few args}

namespace eval foo {
    proc bar {} {return ok}
    namespace eval bar {
        proc baz {} {return ok}
    }
}
is [namespace exists foo] 1 {namespace eval foo: namespace exists}
is [foo::bar]      ok       {namespace eval foo: proc}
is [foo::bar::baz] ok       {namespace eval foo: namespace eval bar: proc}

is [namespace eval foo {set a ok; set a}] ok {namespace eval: return value}
is [namespace eval {}  {set a ok; set a}] ok {namespace eval: implicit global}

proc alias {one two} {
    namespace eval {} [list upvar 0 $one $two]
}
set   foo ok
alias foo bar
is [set bar] ok {namespace eval + proc + upvar}

namespace delete foo
eval_is {namespace exists foo} 0 {namespace delete} {TODO {broken in r30286}}

eval_is {namespace current foo} \
  {wrong # args: should be "namespace current"} \
  {namespace current: too many args}

is [namespace current]                      ::    {namespace current: global}
is [namespace eval foo {namespace current}] ::foo {namespace current: ::foo}


eval_is {namespace parent foo bar} \
  {wrong # args: should be "namespace parent ?name?"} \
  {namespace parent: too many args}

is [namespace parent ""]                   {} {namespace parent: ::}
is [namespace parent foo]                  :: {namespace parent: ::foo (explicit)}
is [namespace eval foo {namespace parent}] :: {namespace parent: ::foo (implicit)}

namespace eval perl6 {
  proc passthrough {val} {
    return $val
  }
  proc pi {} {
    passthrough 3
  }
}
is [perl6::pi] 3 \
  {do procs in namespace default to that namespace when looking for commands?}

namespace eval perl6 {
  namespace export pi
}
namespace import perl6::pi
eval_is {pi} 3 {simple import test}

# we can't do this test until all the file commands work
# ([file delete] in particular)

#set file [open tmp.tcl w]
#puts  $file {proc okay {} {return okay}}
#close $file

#namespace eval foo { source tmp.tcl }
#is [foo::okay] okay {namespace + source}

#file delete tmp.tcl
