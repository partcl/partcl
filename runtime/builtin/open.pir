.HLL 'tcl'
.namespace []

.sub '&open'
    .param pmc argv :slurpy
    .argc()

    .int(args_ok,1)
    .If(argc==0,{args_ok=0})
    .If(argc> 3,{args_ok=0})
    .Unless(args_ok, {
        tcl_error 'wrong # args: should be "open fileName ?access? ?permissions?"'
    })

    .str(fileName,{argv[0]})
    .IfElse(argc==1, {
        .str(pir_access,'r')
    }, {
        .str(pir_access,'')
        .str(  access,{argv[1]})
        # The + modes don't map directly to parrot.
        # Ignoring binary mode (b) for now.
        .If(access=='r', {
            pir_access = 'r'
        })
        .If(access=='r+', {
            pir_access = 'rw'
        })
        .If(access=='w', {
            pir_access = 'w'
        })
        .If(access=='w+', {
            pir_access = 'wr'
        })
        .If(access=='a', {
            pir_access = 'a'
        })
        .If(access=='a+', {
            pir_access = 'a'
        })
     })

    .If(pir_access=='', {
        $S0 = 'invalid access mode "'
        $S0 .= access
        $S0 .= '"'
        tcl_error $S0
    })

    .local pmc channel
    channel = open fileName, pir_access

    $I0 = defined channel
    .Unless($I0, {
       tcl_error 'unable to open specified file'
    })

    .local pmc channels, next_channel_id
    channels        = get_root_global ['_tcl'], 'channels'
    next_channel_id = get_root_global ['_tcl'], 'next_channel_id'

    .str(channel_id,'file')
    # get a new file channel name
    $S0 = next_channel_id
    channel_id .= $S0
    inc next_channel_id

    channels[channel_id] = channel

    .return(channel_id)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
