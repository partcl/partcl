.HLL 'tcl'
.namespace []

.sub '&exec'
  .param pmc argv :slurpy
  .prof('tcl;&exec')

  .local string command
  command = argv
  
  .local int result # XXX ignored
  result = spawnw command

  .return('')
.end


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
