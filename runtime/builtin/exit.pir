.HLL 'tcl'
.namespace []

.sub '&exit'
    .param pmc argv :slurpy
    .argc()

    if argc > 1 goto bad_args

    .local int returnCode
    returnCode = 0
    if argc == 0 goto got_returnCode

    returnCode = shift argv

got_returnCode:

    exit returnCode

bad_args:
    die 'wrong # args: should be "exit ?returnCode?"'
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
