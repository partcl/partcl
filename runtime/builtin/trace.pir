.HLL 'tcl'
.namespace []

# XXX This is just a stub to get spec tests working.
.sub '&trace'
  .param pmc argv :slurpy

  # comment this line to reactivate basic (BUT VERY SLOW) tracing
  .return()

  .local string subcommand
  subcommand = shift argv
  if subcommand != 'variable' goto unimplemented

  .local string name
  name = shift argv

  .local string op
  op = shift argv
  if op != 'r' goto unimplemented

  .local string command
  command = shift argv

  .local pmc variable 
   variable = findVar(name) 

  $S0 = typeof variable
  if $S0 != 'TclArray' goto unimplemented

  .local pmc traced_var
  traced_var = new 'TraceArray'

  # copy all the elements over. 
  .iter(variable)
it_beg:
  unless iterator goto it_end
  $S1 = shift iterator
  $P2 = variable[$S1]
  traced_var[$S1] = $P2
  goto it_beg
it_end:

  copy variable, traced_var

  variable.'set_reader'(command)
unimplemented:
  .return('')
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
