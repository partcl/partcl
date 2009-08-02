.HLL 'tcl'
.namespace []

.sub 'binary_options' :anon :immediate
    .prof('tcl;binary_options')

    .local pmc opts
    opts = split ' ', 'format scan'
    .return(opts)
.end

.sub '&binary'
    .param pmc argv :slurpy

    .prof('tcl;&binary')

    .int(argc, elements argv)
    .Unless(argc, {
      die 'wrong # args: should be "binary option ?arg arg ...?"'
    })

    .str(subcommand_name, shift argv)

    .const 'Sub' options = 'binary_options'

    .local pmc select_option
    select_option  = get_root_global ['_tcl'], 'select_option'

    .local string canonical_subcommand
    canonical_subcommand = select_option(options, subcommand_name)

    .int(argc, elements argv)
    .If(canonical_subcommand=='format', {
        .Unless(argc, {
            die 'wrong # args: should be "binary format formatString ?arg arg ...?"'
        })

        .str(formatString, shift argv)
        .local string binStr
        binStr       = tcl_binary_format formatString, argv
        .return(binStr)
    })

    .If(canonical_subcommand=='scan', {
        .Unless(argc >= 2, {
            die 'wrong # args: should be "binary scan value formatString ?varName varName ...?"'
	})

        .str(value_s     , shift argv)
        .str(formatString, shift argv)

        .pmc(ret, {tcl_binary_scan value_s, formatString})

        .local pmc setVar, variables, values
        setVar = get_root_global ['_tcl'], 'setVar'
        variables = iter argv
        values    = iter ret

        loop:
            unless variables goto end
            unless values    goto end

            .local pmc var, value_p
            var   = shift variables
            value_p = shift values
            setVar(var, value_p)

            goto loop
        end:
        .return('')
    })

    .return ('') # once all commands are implemented, remove this...
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
