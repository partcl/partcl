.HLL 'tcl'
.namespace []

.sub '&incr'
  .param pmc argv :slurpy
  .argc()

  if argc < 1 goto bad_args
  if argc > 2 goto bad_args

  # get helper subs
  .const 'Sub' makeVar = 'makeVar'

  # Get/Vivify variable
  .local pmc varName
  varName = argv[0]
  .local pmc var
  var = makeVar(varName)
  $I0 = defined var
  if $I0 goto got_var
  var = 0
got_var:
  $I0 = var
  var = $I0

  # Increment
  if argc < 2 goto default_increment
  .local int increment
  increment = argv[1]
  var += increment
  goto done_increment
default_increment:
  var += 1

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
