.HLL 'tcl'
.namespace []

.sub '&lrange'
    .param pmc argv :slurpy

    .int (argc, {elements argv})
    .If(argc != 3, {
        die 'wrong # args: should be "lrange list first last"'
    })

    .pmc(list, argv[0])
    list = list.'getListValue'()

    .pmc(first, argv[1])
    .pmc(last,  argv[2])


    .local pmc getIndex
    getIndex = get_root_global ['_tcl'], 'getIndex'

    .int(from, {getIndex(first,list)})
    .int(to,   {getIndex(last, list)})

    .If(from < 0, {from = 0})

    $I0 = elements list
    dec $I0
    .If(to > $I0, {to = $I0})

have_indices:
    .list(retval)    

    .While(from<=to, {
        $P0 = list[from]
        push retval, $P0
        inc from
    })
end:

  .return(retval)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
