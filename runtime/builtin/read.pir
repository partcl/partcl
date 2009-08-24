.HLL 'tcl'
.namespace []

.sub '&read'
  .param pmc argv :slurpy

  # XXX this just supports the [read $channel] variant.

  .local pmc getChannel,channel
  .local string channelId
  getChannel = get_root_global ['_tcl'], 'getChannel'
  channelId = argv[0]
  channel = getChannel(channelId)

  .local string contents
  contents = channel.'readall'()
  .return (contents)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
