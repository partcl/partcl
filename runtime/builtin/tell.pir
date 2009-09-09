.HLL 'tcl'
.namespace []

.sub '&tell'
    .param pmc argv :slurpy
    .argc()

    .const 'Sub' getChannel = 'getChannel'

    .If(argc!=1, {
        tcl_error 'wrong # args: should be "tell channelId"'
    })

    .local pmc channel
    channel = shift argv
    channel = getChannel(channel)

    .local int pos
    pos = tell channel

    .return(pos)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
