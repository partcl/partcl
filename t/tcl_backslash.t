#!perl

# Copyright (C) 2006-2008, The Parrot Foundation.

# the following lines re-execute this as a tcl script
# the \ at the end of these lines makes them a comment in tcl \
use lib qw(lib); # \
use Tcl::Test; #\
__DATA__

source lib/test_more.tcl
plan 35

# no effect in braces
is {a\n} {a\n} {in braces}

is \n \x0a {newline} 
is \t \x09 {tab}
is \b \x08 {backspace}
is \f \x0c {formfeed}
is \r \x0d (carriage return)
is \v \x0b {vertical tab}
is \\ \x5c {backslash}
is \q    q {non-special char}

is "a\
b" "a b"   {backslash/newline subst}

# octal
is \7    \x07                 {octal single}
is \79   [join {"\x07" 9} ""] {octal single extra}
is \12   \x0a                 {octal double}
is \129  [join {"\x0a" 9} ""] {octal double extra}
is \123  S                    {octal triple}
is \1234 S4                   {octal triple extra}

is \xq               xq                 {hex single invalid}
is \x7               \7                 {hex single}
is \x7q              [join {"\7" q} ""] {hex single, extra}
is \x6a              j                  {hex double}
is \x6aq             jq                 {hex double, extra}
is \xb6a             j                  {hex triple, skip ok?}
is \xb6aq            jq                 {hex triple, extra}
is \xaaaaaaaaaaab6a  j                  {hex many}
is \xaaaaaaaaaaab6aq jq                 {hex many, extra}

is \uq   uq               {unicode single invalid}
is \u7   \7               {unicode single}
is \u7q  [join "\7 q" ""] {unicode single, extra}
is \u6a  j                {unicode double}
is \u6aq jq               {unicode double, extra}

# expected values are in utf8 encoding.
# the check for 3/4 digit unicode reps convert between upper and lower
# to insure we parsed it properly.

is \u39b   [string toupper \u3bb]  {unicode three}
is \u39bq  [join {"\u39b" q} ""]   {unicode three, extra}
is \u0453  [string tolower \u0403] {unicode four}
is \u0453q [join {"\u0453" q} ""]  {unicode four,extra}

is \\\a\007\xaaaa07\u0007\uq \
  [join {"\x5c" "\7" "\7" "\7" "\7" u q} ""] {multiple per word}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
