.HLL 'tcl'
.namespace []

.sub '&uplevel'
  .param pmc argv :slurpy
  .argc()

  if argc == 0 goto bad_args

  .local pmc compileTcl, getCallLevel
  compileTcl        = get_root_global ['_tcl'], 'compileTcl'
  getCallLevel    = get_root_global ['_tcl'], 'getCallLevel'
  .local int rethrow_flag

  # save the old call level
  .local pmc call_chain
  .local int call_level
  call_chain = get_root_global ['_tcl'], 'call_chain'
  call_level = elements call_chain

  .local pmc new_call_level
  new_call_level = argv[0]

  .local int defaulted
  (new_call_level,defaulted) = getCallLevel(new_call_level)
  if defaulted == 1 goto skip

  # if we only have a level, then we don't have a command to run!
  if argc == 1 goto bad_args
  # pop the call level argument
  $P1 = shift argv

skip:
  .local int difference
  $I0 = new_call_level
  difference = call_level - $I0

  .list(saved_call_chain)
  $I0 = 0
save_chain_loop:
  if $I0 == difference goto save_chain_end
  $P0 = pop call_chain
  push saved_call_chain, $P0
  inc $I0
  goto save_chain_loop
save_chain_end:

  $S0 = join ' ', argv
  # if we get an exception, we have to reset the environment
  .local pmc retval
  push_eh restore_and_rethrow
    $P0 = compileTcl($S0)
    retval = $P0()
  pop_eh

  rethrow_flag = 0
  goto restore

restore_and_rethrow:
  .catch()
  rethrow_flag = 1
  goto restore

restore:
  # restore the old level
  $I0 = 0
restore_chain_loop:
  if $I0 == difference goto restore_chain_end
  $P0 = pop saved_call_chain
  push call_chain, $P0
  inc $I0
  goto restore_chain_loop
restore_chain_end:
  if rethrow_flag goto rethrow
  .return(retval)

rethrow:
  .rethrow()

bad_args:
  die 'wrong # args: should be "uplevel ?level? command ?arg ...?"'
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
