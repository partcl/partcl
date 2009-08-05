=head1 TclDict

A Tcl hash.

=cut

.HLL 'parrot'
.namespace [ 'TclDict' ]

=head2 class_init

Define the attributes required for the class.

=cut

.sub class_init :anon :load
  $P0 = get_class 'Hash'
  $P1 = subclass $P0, 'TclDict'
.end


=head2 get_string

Returns the dict as a string. Take advantage of the heavy lifting already
present in TclList.

=cut

.sub get_string :vtable

    .local pmc list
    list = root_new ['parrot'; 'TclList']

    .local pmc iterator
    iterator = iter self

    .local pmc key, value
  iter_loop:
    unless iterator goto loop_done
    key = shift iterator
    value = self[key]
    if self == value goto iter_loop  # recursion avoidance
    push list, key
    push list, value

    goto iter_loop
  loop_done:

    .local string retval
    retval = list
    .return(retval)
.end

=head2 getDictValue

=cut

.sub getDictValue :method
    .return(self)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
