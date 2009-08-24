.HLL 'tcl'
.namespace []

.sub '&lassign'
  .param pmc argv :slurpy
  .argc()

  if argc < 2 goto bad_args

  .local pmc retval
  .local pmc list

  # get helper subs
  .local pmc setVar
  setVar = get_root_global ['_tcl'], 'setVar'

  # coerce argument types
  list = shift argv
  list = list.'getListValue'()

  .local string varname, value

var_loop:
  varname = shift argv
  value = shift list
  setVar(varname, value)

  unless list goto list_empty
  if argv goto var_loop

list_empty:
  value = ''
null_loop:
  unless argv goto var_end
  varname = shift argv
  setVar(varname, value)
  branch null_loop

var_end:
  .return(list)

bad_args:
  die 'wrong # args: should be "lassign list varName ?varName ...?"'
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
