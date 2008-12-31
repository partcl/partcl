.HLL 'Tcl'
.namespace []

.sub 'open'
  .param pmc argv :slurpy

  .local string fileName, channel_id, access, pir_access

  .local int argc
  argc = elements argv

  if argc == 0 goto error
  if argc  > 3 goto error

  fileName = argv[0]
  access   = argv[1]
  pir_access = 'r'
  if access == '' goto done_access
  if access == 'r' goto done_access
  # RT#40780: assume r & w are the only options for now.
  pir_access = 'w'

done_access:
  .local pmc channel
  channel = open fileName, pir_access

  $I0 = defined channel
  unless $I0 goto file_error

  .local pmc channels, next_channel_id
  channels        = get_root_global ['_tcl'], 'channels'
  next_channel_id = get_root_global ['_tcl'], 'next_channel_id'

  channel_id = 'file'
  # get a new file channel name
  $S0 = next_channel_id
  channel_id .= $S0
  inc next_channel_id

  channels[channel_id] = channel

  .return(channel_id)

file_error:
  die 'unable to open specified file'

error:
  die 'wrong # args: should be "open fileName ?access? ?permissions?"'
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
