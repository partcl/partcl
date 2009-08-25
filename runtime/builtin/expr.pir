.HLL 'tcl'
.namespace []

.sub '&expr'
    .param pmc argv :slurpy
    .argc()

    .Unless(argc, {
        die 'wrong # args: should be "expr arg ?arg ...?"'
    })

    .const 'Sub' compileExpr = 'compileExpr'

    .str(expr, {join ' ', argv})

    .pmc(interp, getinterp)
    .pmc(ns, {interp['namespace'; 1]})

    .local pmc runnableExpr
    runnableExpr = compileExpr(expr, 'ns'=>ns)
    .tailcall runnableExpr()
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
