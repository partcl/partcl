.HLL 'Tcl'
.namespace []

# In a normal tclsh, load would load only platform specific files. since
# we are running on parrot, we also load .pbc files.

# When loading a pbc file, we don't try to invoke anything; we assume the
# library is configured with appropriate :load-marked subroutines.

.sub '&load'
  .param pmc argv :slurpy

  .local string fileName
  fileName = shift argv

  .local int strlen, pos
  strlen = length fileName
  if strlen < 4 goto fixup
  strlen -=4
  pos = index fileName, '.pbc'
  if strlen == pos goto got_pbc_name

fixup:
  fileName .= '.pbc'

got_pbc_name:
  push_eh failed
    load_bytecode fileName
  pop_eh
  .return('')

failed:
  .catch()
  die 'image not found'
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
