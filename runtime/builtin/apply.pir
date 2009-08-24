.HLL 'tcl'
.namespace []

.sub '&apply'
    .param pmc argv :slurpy
    .argc()

    .If(argc==0, {
        die 'wrong # args: should be "apply lambdaExpr ?arg1 arg2 ...?"'
    })

    .pmc(lambda, argv[0])

    lambda = lambda.'getListValue'()

    .int(elems, elements lambda)

    if elems < 2 goto bad_lambda
    if elems > 3 goto bad_lambda

    tcl_return ''

bad_lambda:
    .str(error, argv[0])
    error  = "can't interpret \"" . error
    error .= "\" as a lambda expression"
    die error
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
