.HLL 'tcl'
.namespace []

# Setup our options...
.sub 'array_options' :immediate :anon
    .local pmc opts
    opts = split ' ', 'anymore donesearch exists get names nextelement set size startsearch statistics unset'
    .return(opts)
.end

.sub '&array'
    .param pmc argv :slurpy
    .argc()

    .If(argc<2, {
        die 'wrong # args: should be "array option arrayName ?arg ...?"'
    })

    .str(subcommand_name, shift argv)

    .const 'Sub' options = 'array_options'

    .local pmc select_option
    select_option  = get_root_global ['_tcl'], 'select_option'

    .local string canonical_subcommand
    canonical_subcommand = select_option(options, subcommand_name)

    .str(array_name, shift argv)
    .null(the_array)

    .local pmc findVar
    findVar = get_root_global ['_tcl'], 'findVar'

    the_array  = findVar(array_name)

    .int(is_array,0)
    .Unless(null the_array, {
        is_array = does the_array, 'associative_array'
    })

    argc = elements argv # count remaining elements

    .If(canonical_subcommand=='exists', {
        .If (argc, {
            die 'wrong # args: should be "array exists arrayName"'
        })

        .return(is_array)
    })

    .If(canonical_subcommand=='size', {
        .If (argc, {
            die 'wrong # args: should be "array size arrayName"'
        })

        .Unless(is_array, {
            .return (0)
        })
        .int(size, the_array)
        .return (size)
    })

    .If(canonical_subcommand=='set', {
        .If (argc!=1, {
            die 'wrong # args: should be "array set arrayName list"'
        })

        .pmc(elems, argv[0])
        elems = elems.'getListValue'()

        .int(count, elems)
        .int(is_odd, count % 2)
        .If(is_odd, {
            die 'list must have an even number of elements'
        })

        .local pmc setVar
        setVar = get_root_global ['_tcl'], 'setVar'

        .If(null the_array, {
            the_array = new 'TclArray'
            setVar(array_name,the_array) # create an empty named array...
        })

        .int(loop, 0)
        .While(loop < count, {
            .str(key, elems[loop])
            inc loop
            .pmc(val, elems[loop])
            inc loop

            # Do this just as if were were calling each set manually, as tcl's
            # error messages indicate it seems to.

            .str(subvar,array_name)
            subvar .= '('
            subvar .= key
            subvar .= ')'
            setVar(subvar, val)
        })
        .return ('')
    })

    .If(canonical_subcommand=='get', {
        .If (argc>1, {
            die 'wrong # args: should be "array get arrayName ?pattern?"'
        })

         # ?pattern? defaults to matching everything.
        .str(match_str, '*')

        .If(argc, {
            match_str = shift argv
        })

        .Unless(is_array, {
            .return ('')
        })

        .pmc(globber, compreg 'Tcl::Glob')
        globber = compreg 'Tcl::Glob'

        .local pmc rule
        rule = globber.'compile'(match_str)

        .local pmc retval
        retval = new 'TclList'

        .pmc(iterator, iter the_array)

        .While(iterator, {
            .str(key, shift iterator)

            # check for match
            $P2 = rule(key)
            .If($P2, {
                push retval, key
                .pmc(val, the_array[key])
                val = clone val
                push retval, val
            })
        })
        .return(retval)
    })

    .If(canonical_subcommand=='unset', {
        .If (argc>1, {
            die 'wrong # args: should be "array unset arrayName ?pattern?"'
        })

        .Unless(is_array, {
            .return('')
         })

        .If (argc>0, {
            .str(match_str, shift argv)

            .local pmc globber
            globber = compreg 'Tcl::Glob'

            .local pmc rule
            rule = globber.'compile'(match_str)

            .pmc(iterator, iter the_array)
            .While(iterator,  {
                .str(key,shift iterator)
                $P2 = rule(key)
                .If ($P2, {
                    delete the_array[key]
                })
            })
            .return ('')
        })

        $P1 = new 'Undef'
        copy the_array, $P1
       .return('')
    })

    .If(canonical_subcommand=='names', {
        .If (argc>2, {
            die 'wrong # args: should be "array names arrayName ?mode? ?pattern?"'
        })

        .str(mode,'-glob')
        .str(pattern, '*')

        .If(argc == 2, {
            mode    = argv[0]
            pattern = argv[1]
        })
        .If(argc == 1, {
            pattern = argv[0]
        })

        .Unless(is_array, {
            .return('')
        })

        .If(mode=='-exact', {
            .pmc(iterator, iter the_array)
            .While(iterator, {
                .str(key, shift iterator)
                .If(key == pattern, {
                    .return(key)
                })
            })
            .return('')
        })
        .If(mode=='-glob', {
            .local pmc globber
            globber = compreg 'Tcl::Glob'

            .local pmc rule
            rule = globber.'compile'(pattern)

            .local pmc retval
            retval = new 'TclList'

            .pmc(iterator, iter the_array)
            .While(iterator, {
                .str(key, shift iterator)
                $P0 = rule(key)
                .If($P0, {
                    push retval, key
                })
            })
            .return(retval)
        })
        .If(mode=='-regexp', {
            .local pmc tclARE
            tclARE = compreg 'PGE::P5Regex'

            .local pmc rule
            rule = tclARE(pattern)

            .local pmc retval
            retval = new 'TclList'

            .pmc(iterator, iter the_array)
            .While(iterator, {
                .str(key, shift iterator)
                $P0 = rule(key)
                .If($P0, {
                    push retval, key
                })
            })
            .return(retval)
        })

        .str(error, 'bad option "')
        error .= mode
        error .= '": must be -exact, -glob, or -regexp'
        die error
    })

    .If(canonical_subcommand=='startsearch', {
        .If (argc, {
            die 'wrong # args: should be "array startsearch arrayName"'
        })
        .Unless(is_array, {
            .str(error, '"')
            error .= array_name
            error .= "\" isn't an array"
            die error
        })

        .tailcall the_array.'new_iter'(array_name)
    })

    .If(canonical_subcommand=='anymore', {
        .If (argc !=1, {
            die 'wrong # args: should be "array anymore arrayName searchId"'
        })
        .Unless(is_array, {
            .str(error, '"')
            error .= array_name
            error .= "\" isn't an array"
            die error
        })

        .str(named, argv[0])

        .local pmc iterator
        iterator = the_array.'get_iter'(named)

        $I0 = istrue iterator
        .return($I0)
    })

    .If(canonical_subcommand=='nextelement', {
        .If (argc !=1, {
            die 'wrong # args: should be "array nextelement arrayName searchId"'
        })
        .Unless(is_array, {
            .str(error, '"')
            error .= array_name
            error .= "\" isn't an array"
            die error
        })

        .str(named, argv[0])

        .local pmc iterator
        iterator = the_array.'get_iter'(named)

        $P0 = shift iterator
        .return($P0)
    })

    .If(canonical_subcommand=='donesearch', {
        .If (argc !=1, {
            die 'wrong # args: should be "array donesearch arrayName searchId"'
        })
        .Unless(is_array, {
            .str(error, '"')
            error .= array_name
            error .= "\" isn't an array"
            die error
        })

        .str(named, argv[0])

        the_array.'rm_iter'(named)
        iterator = the_array.'get_iter'(named)

        .return('')
    })

    .return ('') # once all commands are implemented, remove this...
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
