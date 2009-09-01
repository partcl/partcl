.HLL 'tcl'
.namespace []

.sub '&lappend'
  .param pmc argv :slurpy
  .argc()

  .const 'Sub' setVar  = 'setVar'
  .const 'Sub' readVar = 'readVar'

  .local pmc value, retval
  .local int return_type
  if argc == 0 goto error

  .local string listname
  listname = argv[0]
  .local int cnt
  cnt = 1

  push_eh new_variable
    value = readVar(listname)
  pop_eh

  value  = value.'getListValue'()
  goto loop

new_variable:
  .catch()
  .list(value)

loop:
  if cnt == argc goto loop_done
  $P0 = argv[cnt]
  push value, $P0
  inc cnt
  goto loop
loop_done:

  setVar(listname, value)
  # should be able to return ourselves, but for Issue #2
  .local pmc retval
  retval = clone value
  .return(retval)

error:
  die 'wrong # args: should be "lappend varName ?value value ...?"'

.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
