=head1 String

Contains overrides for the builtin Parrot String type so we can reliably
call Tcl methods on them.

=cut

.HLL 'parrot'
.namespace ['String']

.sub getListValue :method
  # a TclString would know what to do!
  .local pmc tclstring
  tclstring = new 'TclString'
  .local string self_s
  self_s = self
  tclstring = self_s

  .local pmc tcllist
  tcllist = tclstring.'getListValue'()

  copy self, tcllist

  .return(self)
.end
