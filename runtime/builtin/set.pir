.HLL 'tcl'
.namespace []

.sub '&set'
    .param pmc argv :slurpy
    .argc()

    .int(args_ok,1)
    .If(argc < 1, {args_ok=0})
    .If(argc > 2, {args_ok=0})
 
    .Unless(args_ok, {
        die 'wrong # args: should be "set varName ?newValue?"'
    })

    .const 'Sub' readVar = 'readVar'
    .const 'Sub' setVar  = 'setVar'

    .pmc(varName, argv[0])
    .If(argc==2, {
        .pmc(value, argv[1])
        .tailcall setVar(varName, value)
    })
    .tailcall readVar(varName)

.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

