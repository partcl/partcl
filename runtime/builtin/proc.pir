.HLL 'tcl'
.namespace []

.sub '&proc'
    .param pmc argv :slurpy
    .argc()

    .const 'Sub' tclc = 'compileTcl'
    .const 'Sub' splitNamespace = 'splitNamespace'

    .If(argc != 3, {
        tcl_error 'wrong # args: should be "proc name args body"'
    })

    .str(full_name,{argv[0]})
    .pmc(args,     {argv[1]})
    .pmc(body,     {argv[2]})

    .pmc(pirc,{compreg 'PIR'})

    .local pmc code, args_code, defaults
    code      = new 'CodeString'
    args_code = new 'CodeString'
    defaults  = new 'CodeString'
    .str(namespace,'[]')

    .str(name, '')
    .list(ns)

    if full_name == '' goto create

    ns   = splitNamespace(full_name, 1)
    .local int ns_elements
    ns_elements  = elements ns
    if ns_elements == 0 goto create
    name = pop ns

    if ns_elements == 1 goto create

    $P0 = get_hll_namespace ns
    .If(null $P0, {
        $S0 = "can't create procedure \""
        $S0 .= full_name
        $S0 .= '": unknown namespace'
        tcl_error $S0
    })

    namespace = join "'; '", ns
    namespace = "['" . namespace
    namespace .= "']"

create:
  code.'emit'(<<'END_PIR', name, namespace)
.namespace %1
.sub '' :anon
    .param pmc argv :slurpy

    .local pmc call_chain, lexpad
    call_chain = get_root_global ['_tcl'], 'call_chain'
    lexpad = new 'Hash'
    push call_chain, lexpad

    .local pmc info_level
    info_level = get_root_global ['_tcl'], 'info_level'
    $P0 = new 'TclList'
    assign $P0, argv
    unshift $P0, '%0'
    unshift info_level, $P0
END_PIR

    .dict(defaults_info)

    .local pmc arg
    .str(args_usage,'')
    .str(args_info,'')
    args  = args.'getListValue'()
    .int(i,0)
    .int(elems,{elements args})
    .int(min,0)
    .int(max,elems)
    .int(is_slurpy,0)
    if elems == 0 goto args_loop_done
    $I0 = elems - 1
    $S0 = args[$I0]
    if $S0 != 'args' goto args_loop
    is_slurpy = 1
    dec elems
args_loop:
    if i == elems goto args_loop_done
    arg = args[i]
    arg = arg.'getListValue'()

    $S0 = arg[0]
    args_info .= $S0
    args_info .= ' '

    $I0 = elements arg
    .If($I0>2, {
        $S0 = arg
        $S1 = 'too many fields in argument specifier "'
        $S1 .= $S0
        $S1 .= '"'
        tcl_error $S1
    })
    if $I0 == 2 goto default_arg

    min = i + 1
    args_code.'emit'(<<"END_PIR", $S0)
    $P1 = shift argv
    lexpad['$%0'] = $P1
END_PIR

    args_usage .= ' '
    args_usage .= $S0
    goto args_next

default_arg:
    args_code.'emit'(<<'END_PIR', i, $S0, $S1)
    unless argv goto default_%0
    $P1 = shift argv
    lexpad['$%1'] = $P1
END_PIR

    $S0 = arg[0]
    $S1 = arg[1]
    defaults_info[$S0] = $S1

got_default_key:

    defaults.'emit'(<<'END_PIR', i, $S0, $S1)
default_%0:
    $P1 = box '%2'
    lexpad['$%1'] = $P1
END_PIR

    args_usage .= ' ?'
    args_usage .= $S0
    args_usage .= '?'

args_next:
    inc i
    goto args_loop

args_loop_done:
    chopn args_info,  1

    .If(is_slurpy, {
        args_usage .= ' ...'
        args_info  .= ' args'
    })

    code .= <<'END_PIR'
  .argc()
END_PIR

    code.'emit'('  if argc < %0 goto BAD_ARGS', min)
    if is_slurpy goto emit_args
    code.'emit'('  if argc > %0 goto BAD_ARGS', max)

emit_args:
    code .= args_code

    # save anything left into args.
    code.'emit'(<<'END_PIR')
    lexpad['args'] = argv
END_PIR

done_args:
    code.'emit'('  goto ARGS_OK')
    code .= defaults
    code.'emit'(<<'END_PIR', name, args_usage)
    goto ARGS_OK
BAD_ARGS:
  $P0 = pop call_chain
  $P0 = shift info_level
  tcl_error 'wrong # args: should be "%0%1"'
ARGS_OK:
  push_eh is_return
END_PIR

    # Save the parsed body.
    .local string parsed_body, body_reg
    (parsed_body, body_reg) = tclc(body, 'pir_only'=>1)

    code .= parsed_body

    code.'emit'(<<'END_PIR', body_reg)
    pop_eh
was_ok:
    $P0 = pop call_chain
    $P0 = shift info_level
    .return(%0)
END_PIR

    code .= <<'END_PIR'
is_return:
  .catch()
  .get_return_code($I0)
  $P0 = pop call_chain
  $P0 = shift info_level
  if $I0 == .CONTROL_CONTINUE goto bad_continue
  if $I0 == .CONTROL_BREAK    goto bad_break
  if $I0 != .CONTROL_RETURN   goto not_return_nor_ok
  .get_message($P0)
  .return ($P0)
bad_continue:
  tcl_error 'invoked "continue" outside of a loop'
bad_break:
  tcl_error 'invoked "break" outside of a loop'
not_return_nor_ok:
  .rethrow()
.end
END_PIR

    $P0 = pirc(code)

    # the PIR compiler returns an Eval PMC, which contains each sub that
    # was compiled in it. we want the first (and only) one, and we want to
    # put it into a TclProc...
    $P0 = $P0[0]

    .local pmc proc
    proc = new 'TclProc'
    assign proc, $P0

    setattribute proc, 'HLL_source', body

    $P9 = box args_info
    setattribute proc, 'args',       $P9
    setattribute proc, 'defaults',   defaults_info

    # XXX save the original namespace in the 'namespace' attribute...

    # And now store the proc subclass into the appropriate slot in the namespace

    .local pmc ns_target
    ns_target = get_hll_namespace

    .local pmc sub_ns
    .iter(ns)
walk_ns:
    unless iterator goto done_walk
    sub_ns = shift iterator
    ns_target = ns_target[sub_ns]
    goto walk_ns
done_walk:

    name = '&' . name
    ns_target[name] = proc

    .return ('')
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
