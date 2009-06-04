.HLL 'Tcl'
.namespace []

.sub '&llength'
  .param pmc argv :slurpy

  .prof('tcl;&llength')

  # usage
  .local int argc
  argc = elements argv
  if argc != 1 goto bad_args

  # get necessary conversion subs
  .local pmc toList
  toList = get_root_global ['_tcl'], 'toList'
  
  # coerce args
  .local pmc list
  list = argv[0]
  list = toList(list)

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
