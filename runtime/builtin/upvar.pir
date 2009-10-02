.HLL 'tcl'
.namespace []

.sub '&upvar'
    .param pmc argv :slurpy
    .argc()

    .const 'Sub' makeVar = 'makeVar'
    .const 'Sub' findVar = 'findVar'
    .const 'Sub' getCallLevel = 'getCallLevel'
    .const 'Sub' getCallDepth = 'getCallDepth'
    .const 'Sub' getLexPad = 'getLexPad'

    if argc < 2 goto bad_args

    .local pmc call_chain
    call_chain   = get_root_global ['_tcl'], 'call_chain'

    .local int call_level
    call_level = getCallDepth()

    .local int new_call_level, defaulted
    $S0 = argv[0]
    (new_call_level,defaulted) = getCallLevel($S0)
    .Unless(defaulted, {
        delete argv[0]
        dec argc
    })

    $I0 = argc % 2
    if $I0 == 1 goto bad_args

    # for each othervar/myvar pair, created a mapping from
    .int(counter,0)
    .local int difference
    difference = call_level - new_call_level
    .While(counter < argc, {
        .local string old_var, new_var
        old_var = argv[counter]
        inc counter
        new_var = argv[counter]

        .If(new_call_level, {
            $P0 = findVar(new_var, 'depth'=>1)
            .Unless(null $P0, {
                $S0 = 'variable "'
                $S0 .= new_var
                $S0 .= '" already exists'
                tcl_error $S0
            })
        })

        .list(saved_call_chain)
        $I0 = 0
        .While($I0 != difference, {
            $P0 = pop call_chain
            push saved_call_chain, $P0
            inc $I0
         })
    
        $P1 = makeVar(old_var, 'depth'=>1)

        # restore the old level
        $I0 = 0
        .While($I0 != difference, {
           $P0 = pop saved_call_chain
           push call_chain, $P0
           inc $I0
        })

        # because we don't want to use assign here (we want to provide a new
        # alias, not use an existing one), do this work by hand

        .IfElse(call_level, {
            .local pmc lexpad
            lexpad = getLexPad(-1)
            $S0 = '$' . new_var
            lexpad[$S0] = $P1
            inc counter
        },{
            .local pmc ns
            .local string name
            ns   = splitNamespace(new_var, 1)
            name = pop ns
            name = '$' . name

            unshift ns, 'tcl'
            ns = get_root_namespace ns
            ns[name] = $P1
            inc counter
        })
    })
    .return('')

bad_args:
    tcl_error 'wrong # args: should be "upvar ?level? otherVar localVar ?otherVar localVar ...?"'
.end


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
