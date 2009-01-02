.HLL 'Tcl'
.namespace []

.sub '&if'
    .param pmc argv :slurpy

    .local int argc
    argc = elements argv

    .local pmc compileExpr
    compileExpr = get_root_global ['_tcl'], 'compileExpr'

    if argc == 0 goto no_args

    .local pmc ns
    $P0 = getinterp
    ns  = $P0['namespace'; 1]

    # we have to do arg checking first, to make sure we got the proper type of
    # exception. but [expr] checking has to happen before that. so replace each
    # string expression with a Sub that represents it. and while we're at it,
    # strip out the "then"s.

    # convert to the expression to a Sub
    $S0 = argv[0]
    $P0 = compileExpr($S0, 'ns'=>ns)

    $I0 = 1
    if $I0 == argc goto no_script

    argv[0] = $P0

    $S0 = argv[$I0]
    unless $S0 == 'then' goto arg_next

    # we have to do this check first so that "then" shows up in the error
    inc $I0
    if $I0 == argc goto no_script

    dec $I0
    delete argv[$I0]
    dec argc
arg_next:
    inc $I0
    if $I0 == argc goto arg_end

    $S0 = argv[$I0]
    if $S0 == 'elseif' goto arg_elseif
    if $S0 == 'else'   goto arg_else

    # 'else' is optional
    dec $I0
    goto arg_else

arg_elseif:
    inc $I0
    if $I0 == argc goto no_expression

    # convert to the expression to a Sub
    $S0 = argv[$I0]
    $P0 = compileExpr($S0)

    inc $I0
    if $I0 == argc goto no_script

    $I1 = $I0 - 1
    argv[$I1] = $P0

    $S0 = argv[$I0]
    unless $S0 == 'then' goto arg_next

    # we have to do this check first so that "then" shows up in the error
    inc $I0
    if $I0 == argc goto no_script

    dec $I0
    delete argv[$I0]
    dec argc
    goto arg_next

arg_else:
    inc $I0
    if $I0 == argc goto no_script

    inc $I0
    if $I0 != argc goto extra_words_after_else
arg_end:

    # now we can do the actual evaluation
    .local pmc compileTcl, toBoolean
    compileTcl  = get_root_global ['_tcl'], 'compileTcl'
    toBoolean = get_root_global ['_tcl'], 'toBoolean'

    .local pmc    cond
    .local string code
    cond = argv[0]
    code = argv[1]
    $I0  = 1

loop:
    $P1 = cond()
    $I1 = toBoolean($P1)
    unless $I1 goto next
    $P0 = compileTcl(code, 'ns'=>ns)
    .tailcall $P0()

next:
    inc $I0
    if $I0 == argc goto nothing

    $S0 = argv[$I0]
    if $S0 == 'elseif' goto elseif
    if $S0 == 'else'   goto else

    # 'else' is optional
    dec $I0
    goto else

elseif:
    inc $I0
    cond = argv[$I0]
    inc $I0
    code = argv[$I0]
    goto loop

else:
    inc $I0
    code = argv[$I0]
    $P0  = compileTcl(code, 'ns'=>ns)
    .tailcall $P0()

extra_words_after_else:
    die 'wrong # args: extra words after "else" clause in "if" command'

nothing:
    .return('')

no_args:
    die 'wrong # args: no expression after "if" argument'

no_script:
    dec $I0
    $S0 = argv[$I0]
    $S0 = 'wrong # args: no script following "' . $S0
    $S0 = $S0 . '" argument'
    die $S0

no_expression:
    dec $I0
    $S0 = argv[$I0]
    $S0 = 'wrong # args: no expression after "' . $S0
    $S0 = $S0 . '" argument'
    die $S0
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
