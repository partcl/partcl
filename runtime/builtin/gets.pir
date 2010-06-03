.HLL 'tcl'
.namespace []

.sub '&gets'
  .param pmc argv :slurpy
  .argc()

  if argc == 0 goto bad_args
  if argc > 2  goto bad_args

  .local string channelID
  channelID = argv[0]

  .local pmc getChannel
  getChannel = get_root_global ['_tcl'], 'getChannel'

  .local pmc io
  io = getChannel(channelID)

  $S0 = typeof io
  if $S0 == 'Socket' goto stream

  .local string tmps, lastchar
  tmps = readline io

  # simplistic newline chomp
  lastchar = substr tmps,-1
  if lastchar != "\n" goto done
  tmps = chopn tmps, 1
  lastchar = substr tmps,-1
  if lastchar != "\r" goto done
  tmps = chopn tmps, 1

done:
  .return(tmps)

stream:
  # eliminate this newline too?
  $S0 = readline io
  .return($S0)

bad_args:
  die 'wrong # args: should be "gets channelId ?varName?"'
.end


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
