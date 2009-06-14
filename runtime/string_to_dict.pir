.HLL '_Tcl'
.namespace []

.sub listToDict
  .param pmc list

  .prof('_tcl;listToDict')
  .local int sizeof_list
  sizeof_list = elements list

  $I0 = mod sizeof_list, 2
  if $I0 == 1 goto odd_args

  .local pmc result
  result = root_new ['parrot'; 'TclDict']

  .local int pos
  pos = 0

loop:
  if pos >= sizeof_list goto done
  $S1 = list[pos]
  inc pos
  $P2 = list[pos]
  inc pos
  $I0 = isa $P2, 'String'
  if $I0 goto is_string
is_list:
  $P2 = listToDict($P2)
  result[$S1] = $P2
  goto loop

is_string:
  # Can we listify the value here? If so, make it into a dictionary.
  $P3 = toList($P2)
  $I0 = elements $P3
  if $I0 <= 1 goto only_string
  push_eh only_string
    $P3 = listToDict($P3)
  pop_eh
  result[$S1] = $P3
  goto loop

only_string:
  result[$S1] = $P2
  goto loop

done:
  .return (result)

odd_args:
  die 'missing value to go with key'
.end

.sub stringToDict
  .param pmc str

  .prof('_tcl;stringToDict')
  .local pmc list
  list = toList(str)
  .tailcall listToDict(list)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
