.HLL 'tcl'
.namespace []

.sub '&for'
    .param pmc argv :slurpy

    .int(argc, {elements argv})
    .If(argc !=4, {
        die 'wrong # args: should be "for start test next command"'
    })

    # get necessary conversion subs
    .local pmc compileTcl
    compileTcl = get_root_global ['_tcl'], 'compileTcl'
    .local pmc compileExpr
    compileExpr = get_root_global ['_tcl'], 'compileExpr'

    .pmc(start_block, argv[0])
    start_block = compileTcl(start_block)
    .pmc(test_block, argv[1])
    test_block = compileExpr(test_block)
    .pmc(next_block, argv[2])
    next_block = compileTcl(next_block)
    .pmc(body_block, argv[3])
    body_block = compileTcl(body_block)

    .local pmc eh_continue
    eh_continue = root_new ['parrot'; 'ExceptionHandler']
    eh_continue.'handle_types'(.CONTROL_BREAK,.CONTROL_CONTINUE)
    set_addr eh_continue, command_exception

    .local pmc eh_done
    eh_done = root_new ['parrot'; 'ExceptionHandler']
    eh_done.'handle_types'(.CONTROL_BREAK)
    set_addr eh_done, done

    start_block()

loop:
    .pmc(test_result, {test_block()})
    unless test_result goto done
    push_eh eh_continue
        body_block()
    pop_eh
continue:
    push_eh eh_done
        next_block()
    pop_eh
    goto loop

command_exception:
    .catch()
    .get_return_code($I0)
    if $I0 == .CONTROL_CONTINUE goto continue
    # .CONTROL_BREAK fallthrough

done:
    .return('')
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
