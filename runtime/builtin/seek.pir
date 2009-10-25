.HLL 'tcl'
.namespace []

.sub '&seek'
    .param pmc argv :slurpy
    .argc()

    .const 'Sub' getChannel = 'getChannel'
  
    .int(args_ok, 1)
    .If(argc < 2, {
        args_ok = 0
    })
    .If(argc > 3, {
        args_ok = 0
    })
    .Unless(args_ok, {
        tcl_error 'wrong # args: should be "seek channelId offset ?origin?"'
    })

    .local pmc channel
    channel = shift argv
    channel = getChannel(channel)

    .local int offset
    offset = shift argv

    .int(whence, 0)
    .If(argc==3, {
        .str(origin, {pop argv})
        .IfElse(origin=='start', {
            whence = 0
         }, {
            .IfElse(origin=='current', {
                whence = 1
            }, {
                .IfElse(origin=='end', {
                    whence =2
                }, {
                    $S0 = 'bad origin "'
                    $S0 .= origin
                    $S0 .= "must be start, current, or end"
                    tcl_error $S0
                })
            })
        })
    })

    seek channel, offset, whence
    .return('')
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
