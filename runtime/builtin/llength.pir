.HLL 'tcl'
.namespace []

.sub '&llength'
  .param pmc argv :slurpy
  .argc()
  if argc != 1 goto bad_args

  
  # coerce args
  .local pmc list
  list = argv[0]
  list = list.'getListValue'()

  $I0 = elements list
  .return($I0)

bad_args:
  die 'wrong # args: should be "llength list"'
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
