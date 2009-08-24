.HLL 'tcl'
.namespace []

.sub '&while'
    .param pmc argv :slurpy

    .int(argc, {elements argv})
    .If(argc != 2, {
        die 'wrong # args: should be "while test command"'
    })

    # get necessary conversion subs
    .local pmc compileTcl
    compileTcl = get_root_global ['_tcl'], 'compileTcl'
    .local pmc compileExpr
    compileExpr = get_root_global ['_tcl'], 'compileExpr'

    # coerce arguments to proper types
    .pmc(test, argv[0])
    test = compileExpr(test)

    .pmc(body, argv[1])
    body = compileTcl(body)

    .local pmc eh
    eh = new 'ExceptionHandler'
    eh.'handle_types'(.CONTROL_CONTINUE,.CONTROL_BREAK)
    set_addr eh, while_loop_exception

while_loop:
    .pmc(test_result, {test()})
    .Unless(test_result, {
        .return('')
    })

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
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
