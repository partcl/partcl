=head1 TclInt

Contains overrides for our TclInt type

=cut

.HLL 'parrot'
.namespace ['TclInt']

=head2 getListValue

Convert to a List.

=cut

.sub getListValue :method
    .list(retval)
    $I0 = self
    retval[0] = $I0
    .return(retval)
.end
