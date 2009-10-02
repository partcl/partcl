.HLL 'tcl'
.namespace []

.sub '&uplevel'
    .param pmc argv :slurpy
    .argc()

    .const 'Sub' getCallLevel = 'getCallLevel'
    .const 'Sub' getCallDepth = 'getCallDepth'
    .const 'Sub' runUpLevel = 'runUpLevel'

    if argc == 0 goto bad_args

    .local int call_level
    call_level = getCallDepth()

    .local pmc argv0
    argv0 = argv[0]

    .local int new_call_level, defaulted
    (new_call_level,defaulted) = getCallLevel(argv0)

    .Unless(defaulted, {
        # if we only have a level, then we don't have a command to run!
        if argc == 1 goto bad_args

        # pop the call level argument
        $P1 = shift argv
    })

    .local string code
    code = join ' ', argv

    .local int difference
    difference = call_level - new_call_level

    .tailcall runUpLevel(difference,code)

bad_args:
    tcl_error 'wrong # args: should be "uplevel ?level? command ?arg ...?"'
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
