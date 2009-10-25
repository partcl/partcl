.HLL 'tcl'
.namespace []

.sub '&after'
    .param pmc argv :slurpy
    .argc()

    .If (argc==0, {
        die 'wrong # args: should be "after option ?arg arg ...?"'
    })

   .TryCatch({
        .int(msec, argv[0])
        .int(sec , msec / 1000)
        sleep sec
    }, {
        # don't handle any of the other options yet.
    })
 
    .return('')
.end


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
