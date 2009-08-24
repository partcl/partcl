.HLL 'tcl'
.namespace []

.sub '&llength'
    .param pmc argv :slurpy
    .argc()

    .If(argc != 1, {
        die 'wrong # args: should be "llength list"'
    })

    .pmc(list, argv[0])
     list = list.'getListValue'()

    $I0 = elements list
    .return($I0)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
