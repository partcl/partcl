.HLL 'tcl'
.namespace []

# while test body

.sub '&while'
  .param pmc argv :slurpy

  .prof('tcl;&while')

  .local int argc
  argc = elements argv
  if argc != 2 goto bad_args

  # get necessary conversion subs
  .local pmc compileTcl
  compileTcl = get_root_global ['_tcl'], 'compileTcl'
  .local pmc compileExpr
  compileExpr = get_root_global ['_tcl'], 'compileExpr'
  .local pmc toBoolean
  toBoolean = get_root_global ['_tcl'], 'toBoolean'

  # coerce arguments to proper types
  .local pmc test
  test = argv[0]
  test = compileExpr(test)

  .local pmc body
  body = argv[1]
  body = compileTcl(body)

  .local pmc eh
  eh = root_new ['parrot'; 'ExceptionHandler']
  eh.'handle_types'(.CONTROL_CONTINUE,.CONTROL_BREAK)
  set_addr eh, while_loop_exception

while_loop:
  $P0 = test()
  $I0 = toBoolean($P0)
  unless $I0 goto while_loop_done

  push_eh eh
    body()
  pop_eh

  goto while_loop

while_loop_exception:
  .catch()
  .get_return_code($I0)
  if $I0 == .CONTROL_CONTINUE goto while_loop
  # .CONTROL_BREAK, fallthrough to done.

while_loop_done:
  .return('')

bad_args:
  die 'wrong # args: should be "while test command"'
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
