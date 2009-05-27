=head1 TclArray

A Tcl associative array.

Note that our iterators ([array startsearch]) do not exactly follow the
usage of the core tcl ones. We reuse numbers a little more aggressively
due to the underlying workings of the ResizablePMCArray type. Tcl tests
for this numbering scheme so this is failign a few tests in set-old.test

=cut

.HLL 'parrot'
.namespace [ 'TclArray' ]

=head2 class_init

Define the attributes required for the class.

=cut

.sub class_init :anon :load
  $P0 = get_class 'Hash'
  $P1 = subclass $P0, 'TclArray'

  addattribute $P1, 'searches'
  addattribute $P1, 'ids'
.end

.sub init :vtable
  $P1 = new 'Hash'
  setattribute self, 'searches', $P1
  $P1 = new 'ResizablePMCArray'
  setattribute self, 'ids', $P1
.end

.sub does :vtable
  .param string provides

  if provides == 'associative_array' goto yes
  .return(0)
yes:
  .return(1)
.end

=head2 new_iter

Create a new iterator and track it.

=cut

.sub new_iter :method
  .param string array_name

  .local pmc ids, searches
  ids = getattribute self, 'ids'
  searches = getattribute self, 'searches'

  .local int next_id
  next_id = elements searches
  inc next_id

  .local string named
  named = 's-'
  $S0 = next_id
  named .= $S0
  named .= '-'
  named .= array_name
  ids[next_id] = named

  .local pmc iterator
  iterator = iter self
  searches[named] = iterator

  .return (named)
.end

=head2 rm_iter

Remove iterator from our list.

=cut

.sub rm_iter :method
  .param string named

  .local pmc ids, searches
  ids = getattribute self, 'ids'
  searches = getattribute self, 'searches'
  
  $P0 = searches[named]
  if null $P0 goto bad_search
  delete searches[named]

  .local int count, length
  count = 0 
  length = elements ids
 
loop:
   if count >= length goto done
  $S0 = ids[count]
  if $S0 != named goto loop_cont
  delete ids[count]
  goto done
loop_cont:
  inc count
done: 
  .return()

bad_search:
  $S0 = 'illegal search identifier "'
  $S0 .= named
  $S0 .= '"'
  die $S0
.end

=head2 get_iter

Return the named iterator

=cut

.sub get_iter :method
  .param string named

  .local pmc searches
  searches = getattribute self, 'searches'

  $P0 = searches[named]
  if null $P0 goto bad_search
  .return ($P0)

bad_search:
  $S0 = 'illegal search identifier "'
  $S0 .= named
  $S0 .= '"'
  die $S0
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
