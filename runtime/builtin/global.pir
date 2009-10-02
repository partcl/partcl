.HLL 'tcl'
.namespace []

.sub '&global'
  .param pmc argv :slurpy
  .argc()

  if argc == 0 goto badargs

  .const 'Sub' getCallDepth = 'getCallDepth'
  .local int call_level
  call_level = getCallDepth()
  unless call_level goto done # global doesn't work when already global.
  .local pmc lexpad
  .local pmc call_chain
  call_chain = get_root_global ['_tcl'], 'call_chain'
  lexpad = call_chain[-1]

  .local string varname
  .local string sigil_varname

  .iter(argv)

loop:
  unless iterator goto done
  varname = shift iterator
  sigil_varname = '$' . varname

  $P1 = get_hll_global sigil_varname
  unless null $P1 goto has_global
  $P1 = new 'Undef'
  set_hll_global sigil_varname, $P1

has_global:
  lexpad[sigil_varname] = $P1
  goto loop

done:
  .return('')

badargs:
  die 'wrong # args: should be "global varName ?varName ...?"'
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
