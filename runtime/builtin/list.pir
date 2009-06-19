.HLL 'tcl'
.namespace []

.sub '&list'
  .param pmc argv :slurpy
  .prof('tcl;&list')
  .return(argv)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
