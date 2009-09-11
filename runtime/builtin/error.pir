.HLL 'tcl'
.namespace []

.sub '&error'
    .param pmc argv :slurpy
    .argc()

    .int(args_ok, 1)
    .If(argc<1,{args_ok=0})
    .If(argc>3,{args_ok=0})
    .Unless(args_ok, {
        tcl_error 'wrong # args: should be "error message ?errorInfo? ?errorCode?"'
    })

    .str(message,argv[0])

    .If(argc==1, {
        tcl_error message
    })
    .pmc(errorInfo,argv[1])
    .If(argc==2, {
        tcl_error message, errorInfo
    })

    .pmc(errorCode,argv[2])
    tcl_error message, errorInfo, errorCode
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
