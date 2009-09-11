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
    .str(  access,{argv[1]})
    .str(pir_access,'r')
    if access == '' goto done_access
    if access == 'r' goto done_access
    pir_access = 'w'

done_access:
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
