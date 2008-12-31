.HLL 'Tcl'
.namespace []

.sub 'interp'
  .param pmc argv :slurpy

  # XXX just enough to get us through some spec tests.
  .local int argc
  argc = argv
  if argc == 0 goto done
  .local string subcommand
  subcommand = shift argv
  if subcommand == 'alias'  goto alias 
  if subcommand != 'create' goto done
create:
  .local string childName
  childName = pop argv
  # XXX: this creates a command with the name of the child interpreter
  # that doesn't do anything; this stub gets us through some spec tests.
  $S0 = "proc "
  $S0 .= childName
  $S0 .= " {args} {}\n"
  $P0 = compreg "TCL"
  $P1 = $P0($S0)
  $P1()
  .return('')

alias:
  # XXX : /very/ simplistic alias to get us through basic.test
  .local string src,dest
  # XXX this stub provides (something like?) currying
  $P1 = shift argv
  dest =  shift argv
  $P1 = shift argv
  src = join ' ', argv
  .local string code
  code = "proc "
  code .= dest
  code .= " {args} {\n uplevel 1 \""
  code .= src
  code .= " $args\"\n}\n"
  $P0 = compreg "TCL"
  $P1 = $P0(code)
  $P1()
  .return('')

done: 
  .return('')
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
