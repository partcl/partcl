=head1 TclProc

A .Sub with attributes

=cut

.HLL 'parrot'
.namespace [ 'TclProc' ]

=head2 class_init

Define the attributes required for the class.

=cut

.sub class_init :anon :load

  $P0 = get_class 'Sub'
  $P1 = subclass $P0, 'TclProc'

  addattribute $P1, 'namespace'
  addattribute $P1, 'HLL_source'
  addattribute $P1, 'args'
  addattribute $P1, 'defaults'
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
