.HLL 'Tcl'
.namespace []

.sub '&return'
    .param pmc argv :slurpy

do_over:
    .local int argc
    argc = elements argv

    if argc == 0 goto empty
    if argc == 1 goto onearg

    $S0 = argv[0]
    if $S0 == "-options" goto handle_opts

    if argc != 3 goto bad_call
    $S1 = argv[1]
    $S2 = argv[2]

    if $S0 != '-code' goto bad_call
    if $S1 != 'error' goto bad_call

    die $S2

bad_call:
    $S0 = join " ", argv
    $S0 = 'TODO: return does not yet allow: ' . $S0
    die $S0

onearg:
    $P0 = argv[0]
    tcl_return $P0

empty:
    tcl_return ''

handle_opts:
    $P1 = shift argv       # remove literal -options
    $P1 = shift argv # get dictionary.
    $P2 = get_root_global ['_tcl'], 'toDict'
    .local pmc options, iterator, key, value
    options = $P2($P1)
    iterator = iter options
o_loop:
    unless iterator goto do_over
    key = shift iterator
    value = options[key]
    unshift argv, value
    unshift argv, key
    goto o_loop
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
