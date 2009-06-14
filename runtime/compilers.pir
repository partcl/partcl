.HLL '_tcl'
.namespace []

=head2 _Tcl::compileExpr

Given an expression, return a subroutine, or optionally, the raw PIR

=cut

.sub compileExpr
    .param string expression
    .param pmc    ns       :named('ns')       :optional
    .param int    has_ns   :opt_flag

    .prof('_tcl;compileExpr')
    .local pmc parse
    .local pmc match

    if expression == '' goto empty

    parse = get_root_global ['parrot'; 'TclExpr'; 'Grammar'], 'expression'
    match = parse(expression, 'pos'=>0, 'grammar'=>'TclExpr::Grammar')

    unless match goto premature_end
    $I0 = length expression
    $I1 = match.'to'()
    .include 'cclass.pasm'
    $I1 = find_not_cclass .CCLASS_WHITESPACE, expression, $I1, $I0
    unless $I0 == $I1 goto extra_tokens

    .local pmc astgrammar, astbuilder, ast
    astgrammar = new ['TclExpr'; 'PAST'; 'Grammar']
    astbuilder = astgrammar.'apply'(match)
    ast = astbuilder.'get'('past')

    .local string namespace
    namespace = '[]'
    unless has_ns goto build_pir

    $P0 = ns.'get_name'()
    $S0 = shift $P0
    $I0 = elements $P0
    if $I0 == 0 goto build_pir
    $S0 = join "'; '", $P0
    $S0 = "['" . $S0
    $S0 = $S0 . "']"
    namespace = $S0

  build_pir:
    .local pmc pirgrammar, pirbuilder
    .local string result
    pirgrammar = new ['TclExpr'; 'PIR'; 'Grammar']
    pirbuilder = pirgrammar.'apply'(ast)
    result = pirbuilder.'get'('result')

    .local string ret
    ret = ast['ret']

    .local pmc pir
    pir = new 'CodeString'

    pir.'emit'(<<"END_PIR", namespace, result, ret)
.HLL 'Tcl'
.namespace %0
.sub '_anon' :anon
.prof("tcl;%0;_anon")
%1
.if_nan(%2,domain_error)
.return(%2)
.domain_error()
.end
END_PIR

    $P1 = compreg 'PIR'
    $P2 = $P1(pir)
    .return ($P2)

  premature_end:
    $S0 = expression
    $S0 = 'syntax error in expression "' . $S0
    $S0 = $S0 . '": premature end of expression'
    die $S0

  extra_tokens:
    $S0 = expression
    $S0 = 'syntax error in expression "' . $S0
    $S0 = $S0 . '": extra tokens at end of expression'
    die $S0

  empty:
    die "empty expression\nin expression \"\""
.end

=head2 _Tcl::compileTcl

Given a chunk of tcl code, return a subroutine.

=cut

.sub compileTcl
    .param string code
    .param int    pir_only    :named('pir_only') :optional
    .param int    has_pir_only :opt_flag
    .param pmc    ns          :named('ns')       :optional
    .param int    has_ns      :opt_flag
    .param int    bsnl        :named('bsnl')     :optional
    .param int    has_bsnl    :opt_flag
    .param int    wrapper     :named('wrapper')  :optional
    .param int    has_wrapper :opt_flag

    .prof('_tcl;compileTcl')
    .local pmc parse
    .local pmc match

    unless has_bsnl goto end_preamble
    unless bsnl     goto end_preamble
    code = 'backslash_newline_subst'( code )

end_preamble:
    parse = get_root_global ['parrot'; 'TclExpr'; 'Grammar'], 'program'
    match = parse(code, 'pos'=>0, 'grammar'=>'TclExpr::Grammar')

    unless match goto premature_end
    $I0 = length code
    $I1 = match.'to'()
    .include 'cclass.pasm'
    $I1 = find_not_cclass .CCLASS_WHITESPACE, code, $I1, $I0
    unless $I0 == $I1 goto extra_tokens

    .local pmc astgrammar, astbuilder, ast
    astgrammar = new ['TclExpr'; 'PAST'; 'Grammar']
    astbuilder = astgrammar.'apply'(match)
    ast = astbuilder.'get'('past')

    .local string namespace
    namespace = '[]'
    unless has_ns goto build_pir

    $P0 = ns.'get_name'()
    $S0 = shift $P0
    $I0 = elements $P0
    if $I0 == 0 goto build_pir
    $S0 = join "'; '", $P0
    $S0 = "['" . $S0
    $S0 = $S0 . "']"
    namespace = $S0

  build_pir:
    .local pmc pirgrammar, pirbuilder
    .local string result
    pirgrammar = new ['TclExpr'; 'PIR'; 'Grammar']
    pirbuilder = pirgrammar.'apply'(ast)
    result = pirbuilder.'get'('result')

    .local string ret
    ret = ast['ret']

    .local pmc pir
    pir = new 'CodeString'
    unless has_pir_only goto do_wrapper
    unless pir_only goto do_wrapper
    if has_wrapper  goto do_wrapper
    pir = result
    goto only_pir

do_wrapper:
    pir.'emit'(<<"END_PIR", namespace, result, ret)
.HLL 'Tcl'
.loadlib 'tcl_ops'
.namespace %0
.include 'src/macros.pir'
.sub '_anon' :anon
.prof("tcl;%0,_anon")
%1
.return(%2)
.end
END_PIR

    if pir_only goto only_pir
    $P1 = compreg 'PIR'
    $P2 = $P1(pir)
    .return ($P2)

  only_pir:
    .return(pir, ret)

  premature_end:
    say code
    die "program doesn't match grammar"

  extra_tokens:
    $S0 = substr code, $I1
    $S0 = 'extra tokens at end of program: ' . $S0
    die $S0
.end
