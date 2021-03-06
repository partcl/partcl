.HLL 'tcl'
.namespace []

.sub '&catch'
  .param pmc argv :slurpy
  .argc()

  .const 'Sub' setVar  = 'setVar'
  .const 'Sub' readVar = 'readVar'

  .local int retval
  .local pmc code_retval, ns
  .local string varname,sigil_varname,code
  $P0 = getinterp
  ns = $P0['namespace'; 1]

  .local pmc compileTcl
  compileTcl = get_root_global ['_tcl'], 'compileTcl'

  if argc == 0 goto bad_args
  if argc  > 3 goto bad_args

  .local pmc opts
  opts = new 'TclDict'

  code = argv[0]
  push_eh non_ok
    $P2 = compileTcl(code, 'ns' => ns)
    code_retval = $P2()
    retval = .CONTROL_OK
  pop_eh

  goto got_retval

non_ok:
  .catch()
  .get_return_code(retval)
  .get_message(code_retval)

got_retval:
  if argc == 1 goto handle_retval

  varname = argv[1]

  .local pmc opts
  opts = new 'TclDict'

  # Store the caught value in a

  setVar(varname,code_retval)

handle_retval:
  # We need to convert the code
  if retval != .CONTROL_OK goto handle_return
  retval = .TCL_OK
  goto done
handle_return:
  if retval != .CONTROL_RETURN goto handle_break
  retval = .TCL_RETURN
  goto done
handle_break:
  if retval != .CONTROL_BREAK goto handle_continue
  retval = .TCL_BREAK
  goto done
handle_continue:
  if retval != .CONTROL_CONTINUE goto handle_error
  retval = .TCL_CONTINUE
  goto done
handle_error:
  # .CONTROL_ERROR (tcl) .EXCEPTION_DIE (parrot), anything else.
  retval = .TCL_ERROR

done:
  if argc != 3 goto return_val

  .local string optionsVarName
  optionsVarName = argv[2]

  opts['-level']     = 1  # XXX hardcoded
  opts['-code']      = retval
  .local pmc ec,ei
  ec = readVar('::errorCode')
  opts['-errorcode'] = ec
  ei = readVar('::errorInfo')
  opts['-errorinfo'] = ei

  setVar(optionsVarName,opts)

return_val:
  .return(retval)

bad_args:
  die 'wrong # args: should be "catch script ?resultVarName? ?optionVarName?"'
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
