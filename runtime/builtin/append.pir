.HLL 'tcl'
.namespace []

.sub '&append'
    .param pmc argv :slurpy
    .argc()

    .const 'Sub' setVar  = 'setVar'
    .const 'Sub' readVar = 'readVar'

    .If(argc==0, {
        die 'wrong # args: should be "append varName ?value value ...?"'
    })

    .str(name,argv[0])

    .If(argc==1, {
        .tailcall readVar(name)
    })

    .str(value,'')

    .Try({
        value = readVar(name)
    })
    
    .int(looper,1)
    .While( looper!=argc, {
        .str(strVal,argv[looper])
        concat value, value, strVal
        inc looper
    })

    setVar(name, value)
    # should be able to return ourselves, but for Issue #2
    .return(value)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
