.HLL 'Tcl'
.namespace []

.sub '&return'
    .param pmc argv :slurpy

    .local pmc argv_bkp
    argv_bkp = clone argv

do_over:
    .local int argc
    argc = elements argv

    .local pmc message
    message = box ''
    if argc == 0 goto return
    if argc == 1 goto onearg

    .local string opt, opt_val
    .local int type
    type = .TCL_RETURN

    opt = argv[0]
    if opt == "-options" goto handle_opts

process_args:
    argc = elements argv
    if argc == 0 goto ready
    if argc > 1  goto next_arg
    message = shift argv
    goto ready
next_arg:
    opt     = shift argv
    opt_val = shift argv
    if opt == '-code'  goto handle_code
    if opt == '-level' goto handle_level
    goto bad_call # we can't deal with other options yet.

handle_code:
    if opt_val != 'error' goto bad_call
    type = .TCL_ERROR
    goto process_args

handle_level:
    if opt_val != '1' goto bad_call
    # level == 1 is a no op.
    goto process_args

ready:
    if type == .TCL_RETURN goto return

error:
    die message

return:
    tcl_return message

onearg:
    message = argv[0]
    goto return

handle_opts:
    $P1 = shift argv # discard -options
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

bad_call:
    $S0 = join " ", argv_bkp
    $S0 = 'TODO: return does not yet allow: ' . $S0
    die $S0
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
