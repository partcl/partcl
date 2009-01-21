=head1 TclArray

A Tcl associative array.

=cut

.HLL 'parrot'
.namespace [ 'TclArray' ]

.cloneable()

=head2 class_init

Define the attributes required for the class.

=cut

.sub class_init :anon :load
  $P0 = get_class 'Hash'
  $P1 = subclass $P0, 'TclArray'

  addattribute $P1, 'searches'
.end

.sub init :vtable
  $P1 = new 'TclDict'
  setattribute self, 'searches', $P1
.end

.sub does :vtable
  .param string provides

  # XXX workaround a parrot bug - would get arg mismatch error without this,
  # even though we don't actually use self anywhere.
  $P0 = self

  if provides == 'associative_array' goto yes
  .return(0)
yes:
  .return(1)
.end

=for comment

- The searches are named s-<number>-<array name>
- The next number used is the highest given number +1. (so if s-1-a and s-2-3 are in use, s-4-a will be next. if all searches are deleted, numbering begins again at 1)

error messages:

 % array donesearch a asdf
illegal search identifier "asdf"


=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
