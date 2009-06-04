.HLL 'Tcl'
.namespace []

.sub '&linsert'
  .param pmc argv :slurpy

  .prof('tcl;&linsert')

  # make sure we have the right # of args
  .local int argc
  argc = elements argv
  if argc < 3 goto bad_args

  # helper functions
  .local pmc toList
  toList = get_root_global ['_tcl'], 'toList'
  .local pmc getIndex
  getIndex = get_root_global ['_tcl'], 'getIndex'

  # coerce arguments
  .local pmc the_list
  the_list = shift argv
  the_list = toList(the_list)

  .local string position
  position = shift argv

  .local int the_index
  the_index = getIndex(position, the_list)

  $S0 = substr position, 0, 3
  if $S0 != 'end' goto next
  inc the_index

  .local int list_size
next:
  list_size = elements the_list
  if the_index <= list_size goto splice_it

  the_index = list_size  # keep it in the list..

splice_it:
   splice the_list, argv, the_index, 0
  .return (the_list)

bad_args:
  die 'wrong # args: should be "linsert list index element ?element ...?"'
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
