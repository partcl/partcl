.HLL 'tcl'
.namespace []

.sub '&apply'
    .param pmc argv :slurpy
    .argc()

    .If(argc==0, {
        die 'wrong # args: should be "apply lambdaExpr ?arg1 arg2 ...?"'
    })

    .pmc(lambda,{shift argv})
    .str(lambda_str,lambda)
    lambda_str = 'apply {' . lambda_str
    lambda_str .= '}'
    lambda = lambda.'getListValue'()

    .int(elems, elements lambda)

    .local pmc tclproc
    tclproc = new 'TclProc'

    .int(args_ok,1)
    .If(elems<2,{args_ok=0})
    .If(elems>3,{args_ok=0})
    .Unless(args_ok,{
        .str(error,lambda)
        error  = "can't interpret \"" . error
        error .= "\" as a lambda expression"
        tcl_error error
    })
    .pmc(args,lambda[0])
    .pmc(body,lambda[1])

    .null(proc)
    .If(elems==2, {
        proc = tclproc.'create'(args,body,lambda_str)
    })
    .If(elems==3, {
        .str(ns_str, lambda[2])
        .pmc(ns,{splitNamespace(ns_str)})
        $P0 = get_hll_namespace ns
        .If(null $P0, {
            $S0 = 'namespace "::'
            $S0 .= ns_str
            $S0 .= '" not found'
            tcl_error $S0
        })
        proc = tclproc.'create'(args,body,lambda_str,ns)
    })

    # tailcall segfaults
    $P1 = proc(argv :flat)
    .return($P1)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
