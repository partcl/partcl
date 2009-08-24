.HLL 'tcl'
.namespace []

.sub '&global'
  .param pmc argv :slurpy

  .local int argc
  argc = elements argv

  if argc == 0 goto badargs

  .local pmc call_chain
  .local int call_level
  call_chain = get_root_global ['_tcl'], 'call_chain'
  call_level = elements call_chain
  unless call_level goto done # global doesn't work when already global.
  .local pmc lexpad
  lexpad = call_chain[-1]

  .local string varname
  .local string sigil_varname
 
  .local pmc iterator
  iterator = iter argv

loop:
  unless iterator goto done
  varname = shift iterator
  sigil_varname = '$' . varname

  $P1 = get_hll_global sigil_varname
  unless null $P1 goto has_global
  $P1 = root_new ['parrot'; 'Undef']
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
