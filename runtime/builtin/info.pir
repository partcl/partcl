.HLL 'tcl'
.namespace []

.sub 'info_options' :anon :immediate
    .local string commands
    commands = 'args body cmdcount commands complete default exists frame functions globals hostname level library loaded locals nameofexecutable patchlevel procs script sharedlibextension tclversion vars'

    .local pmc opts
    opts = split ' ', commands
    .return(opts)
.end

.sub '&info'
    .param pmc argv :slurpy
    .argc()

    .const 'Sub' select_option = 'select_option'
    .const 'Sub' setVar = 'setVar'
    .const 'Sub' splitNamespace = 'splitNamespace'
    .const 'Sub' readVar = 'readVar'
    .const 'Sub' options = 'info_options'
    .const 'Sub' getCallDepth = 'getCallDepth'
    .const 'Sub' getLexPad = 'getLexPad'

    .If(argc==0, {
        die 'wrong # args: should be "info subcommand ?argument ...?"'
    })

    .str(subcommand, {shift argv})
    # canonicalize the subcommand name.
    subcommand = select_option(options, subcommand)

    .argc()

    .If(subcommand=='args', {
        .If(argc != 1, {
            die 'wrong # args: should be "info args procname"'
        })

        .str(procname, {shift argv})

        .pmc(ns, {splitNamespace(procname)})

         .str(name, {pop ns})
        name = '&' . name
  
        unshift ns, 'tcl'
        $P1 = get_root_global ns, name
        .Unless(null $P1, {
            $P2 = getattribute $P1, 'args'
            .Unless(null $P2, {
                .return($P2)
            })
        })

        $S0 = '"'
        $S0 .= procname
        $S0 .= "\" isn't a procedure"
        die $S0
    })
    .If(subcommand=='body', {
        .Unless(argc == 1, {
            die 'wrong # args: should be "info body procname"'
        })
    
        .str(procname, argv[0])

        .pmc(ns, {splitNamespace(procname)})

        .local string name
        .Try({
            name = pop ns
        })
        name = '&' . name

        unshift ns, 'tcl'
        $P1 = get_root_global ns, name
        .Unless(null $P1, {
            $P2 = getattribute $P1, 'HLL_source'
            .Unless(null $P2, {
                .return($P2)
            })
        })

        $S0 = '"'
        $S0 .= procname
        $S0 .= "\" isn't a procedure"
        die $S0
    })
    .If(subcommand=='complete', {
        .If(argc != 1, {
            die 'wrong # args: should be "info complete command"'
        })

        .pmc(body, argv[0])
        .TryCatch({
            $P1 = compileTcl(body)
            .return(1)
         }, {
            .str(msg, exception)
            .If(msg== 'missing close-brace', {
                    .return(0)
            })
            .If(msg== 'missing close-bracket', {
                    .return(0)
            })
            .If(msg== 'missing "', {
                    .return(0)
            })
            .rethrow()
         })
    })
    .If(subcommand=='default', {
        .If(argc != 3, {
            die 'wrong # args: should be "info default procname arg varname"'
        })

        .str(procname, argv[0])
        .str(argname,  argv[1])
        .str(varname,  argv[2])

        .pmc(ns, {splitNamespace(procname)})
        .str(name, {pop ns})
        name = '&' . name

        unshift ns, 'tcl'

        .local pmc proc
        proc = get_root_global ns, name
        .If(null proc, {
            $S0 = '"'
            $S0 .= procname
            $S0 .= "\" isn't a procedure"
            die $S0
        })

        .local pmc defaults
        defaults = getattribute proc, 'defaults'
        .local pmc args
        args = getattribute proc, 'args'
        if null defaults goto check_arg

        .local pmc arg_defaults
        arg_defaults = defaults[argname]
        if_null arg_defaults, check_arg
        push_eh error_on_set
          setVar(varname, arg_defaults) 
        pop_eh

        # store in variable
        .return (1)

check_arg:
        # there's no default. is there even an arg?
        if null args goto not_argument
        arg_defaults = args.'getListValue'()
        .local string checking_arg
	.iter(arg_defaults)
        .While(iterator, {
            checking_arg = shift iterator
            if checking_arg==argname goto no_default
        })

not_argument:
        $S0 = 'procedure "'
        $S0 .= procname
        $S0 .= "\" doesn't have an argument \""
        $S0 .= argname
        $S0 .= '"'
        die $S0

no_default:
        push_eh error_on_set
          setVar(varname, '')
        pop_eh
        .return (0)

error_on_set:
        .catch()
        $S0 = "couldn't store default value in variable \""
        $S0 .= varname
        $S0 .= '"'
        die $S0
    })
    .If(subcommand=='functions', {
        .If(argc > 1, {
            die 'wrong # args: should be "info functions ?pattern?"'
        })

        .local pmc mathfunc
        mathfunc = get_root_namespace ['tcl'; 'tcl'; 'mathfunc']

        .iter(mathfunc)
        .list(retval)

        .local pmc globber,rule,match
        globber = compreg 'Tcl::Glob'
        if argc == 1 goto got_glob
        $S1 = '&*'
        goto compile
got_glob:
        $S1 = argv[0]
        $S1 = '&' . $S1
compile:
        rule = globber.'compile'($S1)
        .While(iterator, {
            $S0 = shift iterator
            $P0 = mathfunc[$S0]
            match = rule($S0)
            .If(match, {
                $S1 = substr $S0, 1
                push retval, $S1
            })
        })
        .return(retval)
    })
    .int(procs_only,0)
    .If(subcommand=='procs', {
        # this and 'commands' share logic, reuse it.
        .If(argc > 1, {
            tcl_error 'wrong # args: should be "info procs ?pattern?"'
        })
        procs_only = 1
        subcommand='commands'
     }) 
    .If(subcommand=='commands', {
        .If(argc > 1, {
            tcl_error 'wrong # args: should be "info commands ?pattern?"'
        })
        .null(matching)

        .local pmc ns
        ns = get_root_global 'tcl'

        .str(prefix, "")

        .If(argc, {
            $P1 = compreg 'Tcl::Glob'
            .local string pattern
            pattern = argv[0]
    
            .local pmc ns_a
            ns_a = splitNamespace(pattern)

            pattern = pop ns_a

            $I0 = elements ns_a
            .If($I0, {
                prefix = join '::', ns_a
                prefix = '::' . prefix
                prefix = prefix . '::'
            })
  
            .int(ns_size, elements ns_a)
            .If (ns_size, {
	        .iter(ns_a)
                .While(iterator, {
                    .str(key, {shift iterator})
                    ns = ns[key]
                })
            })
    
            matching = $P1.'compile'(pattern)
        })
   
        .list(result)
    
        if null ns goto iter_loop_end
    
        .iter(ns)
      iter_loop:
         unless iterator goto iter_loop_end
         .local pmc nskey
         nskey = shift iterator
         $S1 = nskey
         $S2 = substr $S1, 0, 1
         unless $S2 == '&' goto iter_loop
         .If(procs_only, {
            # Was this written in tcl?
            .local pmc item
            item = ns[nskey]
            .TryCatch({
                $P2 = getattribute item, 'HLL_source'
            }, {
                goto iter_loop
            })
         })
         $S1 = substr $S1, 1
         if_null matching, add_result
         $P2 = matching($S1)
         unless $P2 goto iter_loop
      add_result:
         $S1 = prefix . $S1
         push result, $S1
         goto iter_loop
      iter_loop_end:
    
        .return(result)
    })
    .If(subcommand=='exists', {
        .If(argc != 1, {
            die 'wrong # args: should be "info exists varName"'
        })

        .str(varname, argv[0])

        .TryCatch({
            $P1 = readVar(varname)
            .return (1)
        }, {
            .return (0)
        })
    })
    .If(subcommand=='tclversion', {
        .If(argc != 0, {
            die 'wrong # args: should be "info tclversion"'
        })
        .tailcall readVar('tcl_version')
    })
    .If(subcommand=='patchlevel', {
        .If(argc!=0, {
            die 'wrong # args: should be "info patchlevel"'
        })
        .tailcall readVar('tcl_patchLevel')
    })
    .If(subcommand=='library', {
        .If(argc!=0, {
            die 'wrong # args: should be "info library"'
        })
        $P1 = get_root_global ['tcl'], '$tcl_library'
        $S0 = $P1
        .If($S0=='', {
            die "no library has been specified for Tcl"
        })
        .return($P1)
    })
    .If(subcommand=='vars', {
        .If(argc>1, {
            die 'wrong # args: should be "info vars ?pattern?"'
        })

        $I1 = getCallDepth()
        .IfElse($I1==0, {
            subcommand='globals' # fall through to globals handler.
        }, {
            .local pmc lexpad
            lexpad = getLexPad(-1)

            .list(retval)

            .local string elem
            .iter(lexpad)
            .While(iterator, {
                elem = shift iterator
                $S0  = substr  elem, 0, 1
                elem = replace elem, 0, 1, ''
                .If($S0=='$', {
                    push retval, elem
                })
            })
            .return(retval)
	})
    })
    .If(subcommand=='globals', {
        .If(argc >1, {
          tcl_error 'wrong # args: should be "info globals ?pattern?"'
        })

        .local pmc globber
        globber = compreg 'Tcl::Glob'
  
        .str(pattern,'$*')
        .local pmc ns
        ns = get_root_namespace ['tcl']

        .str(prefix,'')
        .If(argc==1, {
            pattern = shift argv

            .local pmc ns_a
            ns_a = splitNamespace(pattern)
            pattern = pop ns_a
  
            .int(ns_len, {elements ns_a})
            .If(ns_len, {
                prefix = join '::', ns_a
                prefix = '::' . prefix
                prefix = prefix . '::'
            })

            .While(ns_len, {
              $S0 = shift ns_a
              ns = ns[$S0]
              ns_len = elements ns_a
            })
  
            pattern = '$' . pattern
        })

        .list(retval)

        .If(null ns, {
            .return(retval)
        })

        .local pmc rule
        rule = globber.'compile'(pattern)

        .iter(ns)
       
        .local pmc match
        .While(iterator, {
            .str(key, { shift iterator })
            match = rule(key)
            .If(match, {
                # match, strip off leading $
                $S1 = substr key, 1
                $S1 = prefix . $S1
                push retval, $S1
            })
        })
        .return(retval)
    })
    .If(subcommand=='level', {
        .If(argc>1, {
            die 'wrong # args: should be "info level ?number?"'
	})
	.If(argc==0, {
            $I0 = getCallDepth()
            .return($I0)
	})
        # argc ==1 
        .local pmc getCallLevel
        getCallLevel = get_root_global ['_tcl'], 'getCallLevel'

        .local int level
        level = shift argv
        if level >= 0 goto find_info_level
        level = getCallLevel(level)
        .return(level)

      find_info_level:
        .getInfoLevel(level, $P0)
        .return($P0)
    })
    .If(subcommand=='script', {
        $P0 = get_root_global ['_tcl'], '$script'
	.If(null $P0, {
	    .return('')
	})
        .return($P0)
    })
    .If(subcommand=='sharedlibextension', {
        .return(0)
    })
    .If(subcommand=='nameofexecutable', {
        .If(argc, {
            die 'wrong # args: should be "info nameofexecutable"'
        })
        $P1 = get_root_global ['_tcl'], 'nameofexecutable'
        .return($P1)
    })
    .If(subcommand=='loaded', {
        .return(0)
    })
    .If(subcommand=='cmdcount', {
        .return(0)
    })

    .return ('') # once all commands are implemented, remove this...
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
