.HLL 'Tcl'
.namespace []

.sub '&lrange'
  .param pmc argv :slurpy

  .prof('tcl;&lrange')

  .local int argc
  argc = elements argv
  if argc != 3 goto bad_args
  # get necessary conversion subs
  .local pmc a_list
  a_list = argv[0]
  a_list = a_list.'getListValue'()
  .local pmc a_first
  a_first = argv[1]
  .local pmc a_last
  a_last = argv[2]
  .local pmc R
  .local pmc temp

  .local pmc getIndex
  getIndex = get_root_global ['_tcl'], 'getIndex'

  .local int from, to
  from = getIndex(a_first, a_list)
  to   = getIndex(a_last,  a_list)

  if from < 0 goto set_first
have_first:
  $I0 = elements a_list
  dec $I0
  if $I0 < to goto set_last

  goto have_indices

set_first:
  from = 0
  goto have_first

set_last:
  to = $I0

have_indices:
  $I0 = from
  R  = root_new ['parrot'; 'TclList']
loop:
  if $I0 > to goto end
  $P0 = a_list[$I0]
  push R, $P0
  inc $I0
  goto loop
end:
  .return(R)
bad_args:
  die 'wrong # args: should be "lrange list first last"'
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
