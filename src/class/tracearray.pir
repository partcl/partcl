=head1 TraceArray

A [trace]able Tcl Array

=cut

.HLL 'parrot'
.namespace [ 'TraceArray' ]

=head2 class_init

Define the attributes required for the class.

=cut

.sub class_init :anon :load

  $P0 = get_class 'TclArray'
  $P1 = subclass $P0, 'TraceArray'

  addattribute $P1, 'reader'
  addattribute $P1, 'working'
.end

.sub set_reader :method :nsentry
  .param pmc reader

  $S0 = reader
  if $S0 == '' goto skip
  setattribute self, 'reader', reader

skip:
.end

.sub init :vtable
  $P1 = new 'TclInt'
  $P1 = 0
  setattribute self, 'working', $P1
.end

.sub get_pmc_keyed :vtable
  .param pmc key

  .local pmc reader
  reader = getattribute self, 'reader'

  if null reader goto delegate
  .local pmc working
  working = getattribute self, 'working'
  if working goto delegate
  working = 1
  .local string script
  script = reader
  script = "uplevel #0 {" . script
  script .= " {} \""
  $S0 = key
  script .= $S0
  script .= "\" r}"
  $P0 = compreg "TCL"
  $P1 = $P0(script)
  $P1()
  working = 0
delegate:
  # Delegate to our first PMC ancestor.
  $P0 = getattribute self, ['Hash'], 'proxy'
  .local pmc result
  result = $P0[key]
  .return (result)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
