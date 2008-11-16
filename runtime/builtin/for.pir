.HLL 'Tcl'
.namespace []

.sub '&for'
  .param pmc argv :slurpy

  .local int argc
  argc = elements argv
  if argc != 4 goto bad_args
  # get necessary conversion subs
  .local pmc compileTcl
  compileTcl = get_root_global ['_tcl'], 'compileTcl'
  .local pmc compileExpr
  compileExpr = get_root_global ['_tcl'], 'compileExpr'

  .local pmc a_start
  a_start = argv[0]
  a_start = compileTcl(a_start)
  .local pmc a_test
  a_test = argv[1]
  a_test = compileExpr(a_test)
  .local pmc a_next
  a_next = argv[2]
  a_next = compileTcl(a_next)
  .local pmc a_command
  a_command = argv[3]
  a_command = compileTcl(a_command)
  .local pmc temp

  .local pmc eh

  .local pmc toBoolean
  toBoolean = get_root_global ['_tcl'], 'toBoolean'
  a_start()

loop:
  temp = a_test()
  $I0 = toBoolean(temp)
  unless $I0 goto done
  eh = new 'ExceptionHandler'
  eh.'handle_types'(.CONTROL_BREAK,.CONTROL_CONTINUE)
  set_addr eh, command_exception
  push_eh eh
    a_command()
  pop_eh
continue:
  eh = new 'ExceptionHandler'
  eh.'handle_types'(.CONTROL_BREAK)
  set_addr eh, done
  push_eh eh
    a_next()
  pop_eh
  goto loop

command_exception:
  .catch()
  .get_return_code($I0)
  if $I0 == .CONTROL_CONTINUE goto continue
  # .CONTROL_BREAK fallthrough

done:
  .return('')
bad_args:
  die 'wrong # args: should be "for start test next command"'
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
