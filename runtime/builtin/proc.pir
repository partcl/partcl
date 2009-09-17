.HLL 'tcl'
.namespace []

.sub '&proc'
    .param pmc argv :slurpy
    .argc()

    .const 'Sub' tclc = 'compileTcl'
    .const 'Sub' splitNamespace = 'splitNamespace'

    .If(argc != 3, {
        tcl_error 'wrong # args: should be "proc name args body"'
    })

    .str(full_name,{argv[0]})
    .pmc(args,     {argv[1]})
    .pmc(body,     {argv[2]})

    # decompose full_name into a namespace and a short name.
    .str(name,full_name)
    .null(ns)

    .If(full_name!='', {
        ns   = splitNamespace(full_name, 1)
        .local int ns_elements
        ns_elements  = elements ns
        .IfElse(ns_elements, {
           name = pop ns
           .If(ns_elements==1, {
               null ns
           })
        }, {
           name = ''
           null ns
        })
    })

    .If(null ns, {
       .interp()
       $P0 = interp['namespace'; 1]
       ns = $P0.'get_name'()
       $P0 = shift ns # remove the 'tcl'
    })


    $P0 = get_hll_namespace ns
    .If(null $P0, {
        $S0 = "can't create procedure \""
        $S0 .= full_name
        $S0 .= '": unknown namespace'
        tcl_error $S0
    })

    $P0 = new 'TclProc'
    .local pmc proc
    proc = $P0.'create'(args, body, name, ns)

    # XXX save the original namespace in the 'namespace' attribute...
    # And now store the proc subclass into the appropriate slot in the namespace

    .local pmc ns_target
    ns_target = get_hll_namespace

    .local pmc sub_ns
    .iter(ns)
walk_ns:
    unless iterator goto done_walk
    sub_ns = shift iterator
    ns_target = ns_target[sub_ns]
    goto walk_ns
done_walk:
   
    name = '&' . name
    ns_target[name] = proc

    .return ('')
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
