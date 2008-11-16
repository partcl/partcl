.HLL 'Tcl'
.namespace []

.sub '&binary'
    .param pmc argv :slurpy

    .local int argc
    argc = elements argv
    unless argc goto no_args

    .local string subcommand_name
    subcommand_name = shift argv

    .local pmc options
    options = get_root_global ['_tcl'; 'helpers'; 'binary'], 'options'

    .local pmc select_option
    select_option  = get_root_global ['_tcl'], 'select_option'

    .local string canonical_subcommand
    canonical_subcommand = select_option(options, subcommand_name)

    .local pmc subcommand_proc
    null subcommand_proc

    subcommand_proc = get_root_global ['_tcl'; 'helpers'; 'binary'], canonical_subcommand
    if_null subcommand_proc, bad_args
    .tailcall subcommand_proc(argv)

bad_args:
  .return ('') # once all commands are implemented, remove this...

no_args:
    die 'wrong # args: should be "binary option ?arg arg ...?"'
.end

.HLL '_Tcl'
.namespace [ 'helpers'; 'binary' ]

.sub 'format'
    .param pmc argv

    .local int argc
    argc = elements argv
    unless argc goto bad_args

    .local string formatString, binStr
    formatString = shift argv
    binStr       = tcl_binary_format formatString, argv

    .return(binStr)

bad_args:
    die 'wrong # args: should be "binary format formatString ?arg arg ...?"'
.end

.sub 'scan'
    .param pmc argv

    .local int argc
    argc = elements argv
    unless argc >= 2 goto bad_args

    .local string value, formatString
    value        = shift argv
    formatString = shift argv

    .local pmc ret
    ret = tcl_binary_scan value, formatString

    .local pmc setVar, variables, values
    setVar = get_root_global ['_tcl'], 'setVar'
    variables = iter argv
    values    = iter ret
loop:
    unless variables goto end
    unless values    goto end

    .local pmc var, value
    var   = shift variables
    value = shift values
    setVar(var, value)

    goto loop
end:

    .return('')

bad_args:
    die 'wrong # args: should be "binary scan value formatString ?varName varName ...?"'
.end

.sub 'anon' :anon :load
    .local pmc options
    options = new 'TclList'
    push options, 'format'
    push options, 'scan'

    set_root_global ['_tcl'; 'helpers'; 'binary'], 'options', options
.end
# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
