.HLL 'Tcl'
.namespace []

.sub '&gets'
  .param pmc argv :slurpy

  .prof('tcl;&gets')
  .local int argc
  argc = elements argv
  if argc == 0 goto bad_args
  if argc > 2  goto bad_args

  .local string channelID
  channelID = argv[0]

  .local pmc getChannel
  getChannel = get_root_global ['_tcl'], 'getChannel'

  .local pmc io
  io = getChannel(channelID)

  $S0 = typeof io
  if $S0 == 'TCPStream' goto stream

  .local string tmps, lastchar
  tmps = readline io

  # simplistic newline chomp
  lastchar = substr tmps,-1
  if lastchar != "\n" goto done
  chopn tmps, 1
  lastchar = substr tmps,-1
  if lastchar != "\r" goto done
  chopn tmps, 1

done:
  .return(tmps)

stream:
  # eliminate this newline too?
  .tailcall io.'readline'()

bad_args:
  die 'wrong # args: should be "gets channelId ?varName?"'
.end


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
