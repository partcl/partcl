.HLL 'Tcl'
.namespace []

.sub 'rename'
  .param pmc argv :slurpy

  .local int argc
  argc = elements argv
  if argc != 2 goto bad_args

  .local string oldName, newName
  oldName = argv[0]
  newName = argv[1]

  .local pmc sub, args, builtin, ns

  $P1 = getinterp
  ns = $P1['namespace'; 1]

  sub = ns[oldName]
  if null sub goto doesnt_exist

  # if the newName is '', just delete the sub
  if newName != '' goto add_sub

delete_only:
  delete ns[oldName]
  .return('') 

add_sub:
  $P0 = ns[newName]
  unless null $P0 goto already_exists
  ns[newName] = sub
  .return('')

already_exists:
  $S0 = "can't rename to \""
  $S0 .= newName
  $S0 .= '": command already exists'
  die $S0

doesnt_exist:
  if newName == '' goto cant_delete

  $S0 = "can't rename \""
  $S0 .= oldName
  $S0 .= "\": command doesn't exist"
  die $S0

cant_delete:
  $S0 = "can't delete \""
  $S0 .= oldName
  $S0 .= "\": command doesn't exist"
  die $S0

bad_args:
  die 'wrong # args: should be "rename oldName newName"'
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
