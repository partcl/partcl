.HLL 'tcl'
.namespace []

.sub '&read'
    .param pmc argv :slurpy
    .argc()

    .const 'Sub' getChannel = 'getChannel'

    .int(args_ok, 0)
    .int(nonewline, 0)
    .int(numChars, 0)
    .int(allChars, 1)
    
    .local string channelName

    .If(argc == 1, {
        args_ok = 1
        channelName = argv[0]
    })

    .If(argc == 2, {
        args_ok = 1
        $S0 = argv[1]
        .IfElse($S0=="-nonewline", {
            nonewline = 1
            channelName = argv[1]
        }, {
            channelName = argv[0]
            numChars    = argv[1]
            allChars = 0
        })
        channelName = argv[0]           
    })

    .Unless(args_ok, { 
        tcl_error 'wrong # args: should be "read channelId ?numChars?" or "read ?-nonewline? channelId"'
    })

    .pmc(channel, {getChannel(channelName)})
   
    .str(contents,'')

    .IfElse(allChars, {
        contents = channel.'readall'()
        .Unless(nonewline, {
            $S0 = substr contents, -1, 1
            .If($S0=="\n", {
                contents = replace contents, -1, 1, ''
            })
        })
    }, {
        .If(numChars!=0, {
            contents = channel.'read'(numChars)
        })
    })
    .return(contents)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
