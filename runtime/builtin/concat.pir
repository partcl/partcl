.HLL 'tcl'
.namespace []

.sub '&concat'
  .param pmc argv :slurpy

  .local int argc
  argc = elements argv

  .local string retval
  retval = ''

  .local int arg_num
  arg_num = 0
  .local string current_arg, trimmed_string
  .local int start_pos,end_pos,str_length,current_char

  .local int first_time
  first_time = 1
arg_loop:
  if arg_num == argc goto arg_loop_done

  $P1 = argv[arg_num]
  current_arg = $P1
  # empty elements don't count
  if current_arg == '' goto arg_loop_next


loop_init:

  # Trim off leading and trailing space on the arg.
  start_pos = 0
  end_pos = length current_arg

left_loop:
  if start_pos == end_pos goto right_done
  $I0 = is_cclass .CCLASS_WHITESPACE, current_arg, start_pos
  if $I0 == 0 goto left_done
  inc start_pos
  goto left_loop

left_done:
  dec end_pos

right_loop:
  $I0 = is_cclass .CCLASS_WHITESPACE, current_arg, end_pos
  if $I0 == 0 goto right_done
  dec end_pos
  goto right_loop

right_done:
  str_length = end_pos - start_pos
  inc str_length
  trimmed_string = substr current_arg, start_pos, str_length

  # elements that are all whitespace don't count
  if trimmed_string == '' goto arg_loop_next

  # Escape any special characters from string. Currently,
  # this is backslashes.

  if first_time goto append_string
  retval .= ' '
append_string:
  first_time = 0
  retval .= trimmed_string

arg_loop_next:
  inc arg_num
  goto arg_loop

arg_loop_done:

done:
  .return(retval)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
