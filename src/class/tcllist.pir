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

=head2 reverse

Reverse ourselves.

This algorithm is very generic and could easily be
moved back into parrot core where we'd be happy to inherit it.

=cut

.sub reverse :method
    .local int low,high
    low = 0
    high = elements self

    .local pmc swap1, swap2
  loop:
    if low >= high goto done
    dec high
    swap1 = self[low]
    swap2 = self[high]
    self[low] = swap2
    self[high] = swap1
    inc low
    goto loop
  done: 
    .return(self)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
