.HLL 'tcl'
.namespace []

.sub '&join'
  .param pmc argv :slurpy

  # usage
  .local int argc
  argc = elements argv
  if argc < 1 goto bad_args
  if argc > 2 goto bad_args

  # coerce args
  .local pmc list
  list = argv[0]
  list = list.'getListValue'()

  # get default string
  .local string joinString
  if argc < 2 goto default_joinString
  joinString = argv[1]
  goto done_joinString
default_joinString:
  joinString = ' '
done_joinString:

  $S0 = join joinString, list
  .return ($S0)

bad_args:
  tcl_error 'wrong # args: should be "join list ?joinString?"'
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
