.HLL 'Tcl'
.namespace []

.sub '&unset'
  .param pmc argv :slurpy

  .local int argc
  argc = elements argv
  if argc == 0 goto loop_end

  .local int i
  i = 0

  .local int nocomplain
  nocomplain = 0

  $S0 = argv[0]
  if $S0 == '--' goto no_flags
  if $S0 != '-nocomplain' goto flags_done
  nocomplain = 1
  i = 1

  if argc < 2 goto flags_done
  $S0 = argv[1]
  if $S0 != '--' goto flags_done
  i = 2
  goto flags_done

no_flags:
  i = 1

flags_done:
  .local pmc find_var, var
  find_var = get_root_global ['_tcl'], 'findVar'

  .local string name
loop:
  if i == argc goto loop_end
  name = argv[i]
  # is this an array?
  # ends with )
  .local int char
  char = ord name, -1
  if char != 41 goto scalar
  # contains a (
  char = index name, '('
  if char == -1 goto scalar

array:
  .local string array_name
  array_name = substr name, 0, char

  .local string key
  .local int len
  len = length name
  len -= char
  len -= 2
  inc char
  key = substr name, char, len

  var = find_var(array_name)
  if null var goto no_such_var
  $I0 = does var, 'associative_array'
  unless $I0 goto variable_isnt_array

  $I0 = exists var[key]
  if $I0 == 0 goto no_such_element
  delete var[key]
  goto next

variable_isnt_array:
  if nocomplain goto next
  $S0 = "can't unset \""
  $S0 .= name
  $S0 .= "\": variable isn't array"
  die $S0

no_such_element:
  if nocomplain goto next
  $S0 = "can't unset \""
  $S0 .= name
  $S0 .= '": no such element in array'
  die $S0

scalar:
  var = find_var(name)
  if null var goto no_such_var

  $P1 = new 'Undef'
  copy var, $P1
  # goto next

next:
  inc i
  goto loop

loop_end:
  .return('')

no_such_var:
  if nocomplain goto next
  $S0 = "can't unset \""
  $S0 .= name
  $S0 .= '": no such variable'
  die $S0
.end


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
