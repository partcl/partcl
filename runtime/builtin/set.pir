.HLL 'Tcl'
.namespace []

.sub '&set'
  .param pmc argv :slurpy

  # check usage
  .local int argc
  argc = elements argv
  if argc < 1 goto bad_args
  if argc > 2 goto bad_args

  .local pmc varName
  varName = argv[0]

  if argc == 2 goto set

get:
  .local pmc readVar
  readVar = get_root_global ['_tcl'], 'readVar'
  .tailcall readVar(varName)

set:
  .local pmc value
  value = argv[1]

  .local pmc setVar
  setVar = get_root_global ['_tcl'], 'setVar'

  .tailcall setVar(varName, value)


bad_args:
  die 'wrong # args: should be "set varName ?newValue?"'
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

