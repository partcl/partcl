.HLL 'tcl'
.namespace []

.sub '&foreach'
  .param pmc argv :slurpy
  .argc()

  .const 'Sub' setVar = 'setVar'
  .const 'Sub' compileTcl = 'compileTcl'

  # Requires multiple of 3 args.
  # Were we passed the right # of arguments? (2n+1)
  if argc < 2 goto bad_args
  $I0 = argc % 2
  if $I0 != 1 goto bad_args

  .local pmc ns
  $P0 = getinterp
  ns  = $P0['namespace'; 1]

  .list(varLists)
  .list(lists)

  .local pmc command
  command  = pop argv
  command  = compileTcl(command, 'ns'=>ns)

  .int(iterations,0)
  .iter(argv)
arg_loop:
  unless iterator goto arg_done

  .local pmc varList, list
  varList = shift iterator
  varList = varList.'getListValue'()

  list    = shift iterator

  # XXX This shouldn't be necessary; r578 somehow caused this to start
  #     receiving .Sub's, which it shouldn't get. This bandaid lets us
  #     run the spectests again.
  .TryCatch({
    list    = list.'getListValue'()
  }, {
    .list(list)
    })

  $I0 = elements varList
  if $I0 == 0 goto bad_varlist

  $I1 = elements list
  $N0 = $I0
  $N1 = $I1
  $N0 = $N1 / $N0
  $I0 = ceil $N0

  list = iter list
  push varLists, varList
  push lists, list

  if $I0 <= iterations goto arg_loop
  iterations = $I0
  goto arg_loop
arg_done:

  .local pmc eh
  eh = new 'ExceptionHandler'
  eh.'handle_types'(.CONTROL_BREAK,.CONTROL_CONTINUE)
  set_addr eh, handle_continue

 .local int iteration
  iteration = -1
next_iteration:
  inc iteration
  if iteration >= iterations goto done

  .local int counter, elems
  counter = -1
  elems   = elements varLists
next_varList:
  inc counter
  if counter >= elems goto execute_command

  .local pmc varList, list
  varList = varLists[counter]
  list    = lists[counter]

  $I0 = -1
  $I1 = elements varList
next_variable:
  inc $I0
  if $I0 >= $I1 goto next_varList

  .local string varname
  varname = varList[$I0]

  .local pmc value
  unless list goto empty_var
  value = shift list
  value = clone value
  setVar(varname, value)
  goto next_variable

empty_var:
  setVar(varname, '')
  goto next_variable

execute_command:
  push_eh eh
    command()
  pop_eh
  goto next_iteration

handle_continue:
  .catch()
  .local int return_type
  .get_return_code(return_type)
  if return_type == .CONTROL_CONTINUE goto next_iteration
  # .CONTROL_BREAK fallthrough

done:
  .return('')

bad_args:
  die 'wrong # args: should be "foreach varList list ?varList list ...? command"'

bad_varlist:
  die 'foreach varlist is empty'
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
