.HLL 'Tcl'
.namespace []

.sub '&incr'
  .param pmc argv :slurpy

  .prof('tcl;&incr')

  # check usage
  .local int argc
  argc = elements argv
  if argc < 1 goto bad_args
  if argc > 2 goto bad_args

  # get helper subs
  .local pmc toInteger
  toInteger = get_root_global ['_tcl'], 'toInteger'
  .local pmc makeVar
  makeVar = get_root_global ['_tcl'], 'makeVar'

  # Get/Vivify variable
  .local pmc varName
  varName = argv[0]
  .local pmc var
  var = makeVar(varName)
  $I0 = defined var
  if $I0 goto got_var
  var = 0
got_var:
  var = toInteger(var)

  # Increment
  if argc < 2 goto default_increment
  .local pmc increment
  increment = argv[1]
  increment = toInteger(increment)
  var += increment
  goto done_increment
default_increment:
  inc var

done_increment:
  .return(var)

bad_args:
  die 'wrong # args: should be "incr varName ?increment?"'
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
