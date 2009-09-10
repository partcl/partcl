.HLL 'tcl'
.namespace []

.sub '&flush'
    .param pmc argv :slurpy
    .argc()

    .const 'Sub' getChannel = 'getChannel'
    .If(argc!=1, {
        tcl_error 'wrong # args: should be "flush channelId"'
    })

    .pmc(channel,{shift argv})
    channel = getChannel(channel)

    $I0 = can channel, 'flush'
    .If($I0, {
        channel.'flush'()
    })

    .return('')
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
