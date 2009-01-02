.HLL 'Tcl'
.namespace []

.sub '&format'
  .param pmc argv :slurpy

  .local int argc
  argc = elements argv
  if argc == 0 goto noargs

  # XXX sprintf can't handle a unicode format/args; if you pass in a unicode
  # string as an argument, it fails with an uncatchable parrot assertion
  # so, let's avoid that the hard way.

  $I0 = find_encoding 'fixed_8'

  $P1 = iter argv
loop:
  unless $P1 goto eloop
  $S1 = shift $P1
  $I1 = encoding $S1
  if $I0 == $I1 goto loop
  .return("XXX format can't handle unicode yet.")
eloop:

  # pull off the format string.
  .local string format
  shift format, argv

  $S0 = sprintf format, argv

  .return($S0)

noargs:
  die 'wrong # args: should be "format formatString ?arg arg ...?"'
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
