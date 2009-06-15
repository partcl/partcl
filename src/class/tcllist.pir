=head1 TclList

Overrides to the TclList pmc

=cut

.HLL 'parrot'
.namespace [ 'TclList' ]

=head2 getListValue

Return a list-ified version of this Tcl PMC.

=cut

.sub getListValue :method
  .return(self)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
