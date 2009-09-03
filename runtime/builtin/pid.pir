.HLL 'tcl'
.namespace []

.sub '&pid'
    .param pmc argv :slurpy
    .argc()

    .If(argc==0, {
        .null(lib)
        .local pmc getpid_c
        getpid_c = dlfunc lib, 'getpid', 'i'
        $I0 = getpid_c()
        .return($I0)
    })
    .If(argc==1, {
        # XXX we don't track these yet.
        .return(99999)
    })


    tcl_error 'wrong # args: should be "pid ?channelId?"'
.end


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
