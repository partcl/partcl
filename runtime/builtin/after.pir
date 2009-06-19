.HLL 'tcl'
.namespace []

.sub '&after'
  .param pmc argv :slurpy

  .prof('tcl;&after')
  .local int argc
  argc = elements argv
  if argc == 0 goto bad_args

  $I0 = argv[0]
  $N0 = $I0 / 1000
  sleep $N0

  .return('')

bad_args:
  die 'wrong # args: should be "after option ?arg arg ...?"'
.end


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
