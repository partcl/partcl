.HLL 'tcl'
.namespace []

.sub 'subst_options' :anon :immediate
    .local pmc opts
    opts = split ' ', 'nobackslashes nocommands novariables'

    .return(opts)
.end

.sub '&subst'
    .param pmc argv :slurpy

    .const 'Sub' options = 'subst_options'

    .local pmc select_switches, switches
    select_switches  = get_root_global ['_tcl'], 'select_switches'

    switches = select_switches(options, argv)
    .argc()

    if argc == 0 goto badargs
    if argc > 1  goto badswitch

    .local string str, newstr
    str = argv[0]

    .local int nobackslashes, nocommands, novariables
    nobackslashes = exists switches['nobackslashes']
    nocommands    = exists switches['nocommands']
    novariables   = exists switches['novariables']

    .local int pos, len
    pos = 0
    len = length str
    .local pmc parse, match, astgrammar, pirgrammar
    astgrammar = new ['TclExpr'; 'PAST'; 'Grammar']
    pirgrammar = new ['TclExpr'; 'PIR'; 'Grammar']

    .local pmc splitNamespace, ns
    .local string namespace
    splitNamespace = get_root_global ['_tcl'], 'splitNamespace'
    ns          = splitNamespace('', 2)
    namespace   = '[]'
    $I0 = elements ns
    if $I0 == 0 goto loop

    namespace = join "'; '", ns
    namespace = "['" . namespace
    namespace .= "']"
loop:
    if pos >= len goto done
    $S0 = substr str, pos, 1
    if $S0 == '[' goto command
    if $S0 == '$' goto variable
    if $S0 == '\' goto backslash
next:
    inc pos
    goto loop

command:
    if nocommands goto next
    parse = get_root_global ['parrot'; 'TclExpr'; 'Grammar'], 'subst_command'
    goto subst

variable:
    if novariables goto next
    parse = get_root_global ['parrot'; 'TclExpr'; 'Grammar'], 'subst_variable'
    goto subst

backslash:
    if nobackslashes goto next
    parse = get_root_global ['parrot'; 'TclExpr'; 'Grammar'], 'subst_backslash'
    goto subst

subst:
    match = parse(str, 'pos'=>pos, 'grammar'=>'TclExpr::Grammar')

    .local pmc astbuilder, ast
    astbuilder = astgrammar.'apply'(match)
    ast        = astbuilder.'get'('past')

    .local pmc pirbuilder
    .local string code
    pirbuilder = pirgrammar.'apply'(ast)
    code       = pirbuilder.'get'('result')

    .local string ret
    ret = ast['ret']

    .local pmc pir
    pir = new 'StringBuilder'

    pir.'append_format'(<<"END_PIR", namespace, code, ret)
.HLL 'tcl'
.namespace %0
.sub '_anon' :anon
%1
.return(%2)
.end
END_PIR

    $P1    = compreg 'PIR'
    $P1    = $P1(pir)
    newstr = $P1()

    $I0 = match.'to'()
    $I1 = $I0 - pos
    str = replace str, pos, $I1, newstr

    pos = $I0
    $I0 = length newstr
    $I0 -= $I1
    pos += $I0
    len += $I0
    goto loop

done:
  .return (str)

badargs:
    die 'wrong # args: should be "subst ?-nobackslashes? ?-nocommands? ?-novariables? string"'

badswitch:
    $S0 = argv[0]
    $S0 = 'bad switch "' . $S0
    $S0 .= '": must be -nobackslashes, -nocommands, or -novariables'
    die $S0
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
