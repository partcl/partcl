.HLL 'tcl'
.namespace []

.sub '&lset'
  .param pmc argv :slurpy
  .argc()

  if argc < 2 goto wrong_args

  .local string name, value
  name  = argv[0]
  value = pop argv
  dec argc

  .local pmc readVar, setVar
  readVar = get_root_global ['_tcl'], 'readVar'
  setVar  = get_root_global ['_tcl'], 'setVar'

  .local pmc retval, list, original_list
  original_list = readVar(name)
  list = clone original_list
  list = list.'getListValue'()
  retval = list

  # we removed the value, so this would be one now
  if argc == 1 goto replace

lset:
  .local pmc getIndex
  getIndex = get_root_global ['_tcl'], 'getIndex'

  unless argc == 2 goto iterate
  $P0 = argv[1]
  $P0 = $P0.'getListValue'()
  $I0 = elements $P0
  if $I0 == 0 goto replace

iterate:
  .local pmc indices, prev
  .local int outer_i
  outer_i = 0
outer_loop:
  inc outer_i
  if outer_i == argc goto done
  indices = argv[outer_i]
  indices = indices.'getListValue'()

  $I0 = 0
  $I1 = elements indices
loop:
  if $I0 == $I1 goto outer_loop

  $P0 = indices[$I0]
  $I2 = getIndex($P0, list)
  if $I2 < 0 goto out_of_range
  $I3 = elements list
  if $I2 >= $I3 goto out_of_range

  prev = list
  list = list[$I2]
  list = list.'getListValue'()
  prev[$I2] = list

  inc $I0
  goto loop

done:
  prev[$I2] = value
  setVar(name, retval)
  original_list = copy retval
  .return(retval)

out_of_range:
  die 'list index out of range'

wrong_args:
  die 'wrong # args: should be "lset listVar index ?index...? value"'

replace:
  .tailcall setVar(name, value)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
