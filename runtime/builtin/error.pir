.HLL 'tcl'
.namespace []

.sub '&error'
  .param pmc argv :slurpy
  .argc()

  if argc < 1 goto badargs
  if argc > 3 goto badargs

  .local pmc message, errorInfo, errorCode
  if argc == 3 goto arg_3
  if argc == 2 goto arg_2

  errorInfo = box ''
  errorCode = box 'NONE'
  goto finish

arg_3:
  errorInfo = argv[1]
  errorCode = argv[2]
  goto finish

arg_2:
  errorCode = box 'NONE'
  errorInfo = argv[1]

finish:
  $P1 = get_hll_global '$errorInfo'
  assign $P1, errorInfo
  $P1 = get_hll_global '$errorCode'
  assign $P1, errorCode

  message = argv[0]
  die message

badargs:
  die 'wrong # args: should be "error message ?errorInfo? ?errorCode?"'
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
