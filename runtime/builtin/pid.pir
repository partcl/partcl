.HLL 'tcl'
.namespace []

.sub '&pid'
  .param pmc argv :slurpy
  .prof('tcl;&pid')
  .return(99999)
.end


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
