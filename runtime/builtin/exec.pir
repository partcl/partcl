.HLL 'tcl'
.namespace []

.sub '&exec'
  .param pmc argv :slurpy

  # XXX We aren't yet able to parse any of the tcl command metachars, so skip them
  .list(cmd_args)

  .iter(argv)

  .local string arg, char
  loop:
    unless iterator goto done
    arg = shift iterator
    char = substr arg, 0, 1
    if char == '|' goto loop
    if char == '<' goto loop
    if char == '>' goto loop
    if char == '2' goto loop
    if char == '@' goto loop
    push cmd_args, arg
    goto loop
  done:

  .local string command
  command = cmd_args

  .local int result # XXX ignored
  result = spawnw command

  .return('')
.end


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
