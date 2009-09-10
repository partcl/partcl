=head2 [namespace]

Parrot has its own namespaces which Tcl is only a part of. So, in the top
level parrot namespace, C<tcl> refers to the top of the Tcl namespace.

To refer back to something in another parrot namespace, use the special
C<parrot> namespace inside Tcl - this should be an alias back to parrot's
real top level namespace.

=cut

.HLL 'tcl'
.namespace []

.sub 'namespace_options' :anon :immediate
    .local pmc opts
    opts = split ' ', 'children code current delete ensemble eval exists export forget import inscope origin parent path qualifiers tail unknown upvar which'

    .return(opts)
.end

.sub 'namespace_wrapper' :anon :immediate
    .return(<<'END_PIR')
.HLL 'tcl'
.namespace %0
# src/compiler.pir :: namespace eval
.sub compiled_tcl_sub_%2
  %1
  .return(%3)
.end
END_PIR

.end

.sub '&namespace'
    .param pmc argv :slurpy
    .argc()

    .const 'Sub' options = 'namespace_options'
    .const 'Sub' select_option = 'select_option'
    .const 'Sub' splitNamespace = 'splitNamespace'

    .Unless(argc, {
        die 'wrong # args: should be "namespace subcommand ?arg ...?"'
    })

    .str(subcommand, {shift argv})
    subcommand = select_option(options, subcommand)
    .argc()


    .null(subcommand_proc)
    subcommand_proc = get_root_global ['_tcl';'helpers';'namespace'], subcommand

    if null subcommand_proc goto bad_args

    .tailcall subcommand_proc(argv)

bad_args:
  .return ('') # once all commands are implemented, remove this...
.end

.HLL '_tcl'
.namespace [ 'helpers'; 'namespace' ]

.sub 'current'
    .param pmc argv
    .argc()

    .If(argc, {
        die 'wrong # args: should be "namespace current"'
    })
    .local pmc ns
    ns  = splitNamespace('')
    $S0 = join '::', ns
    $S0 = '::' . $S0
    .return($S0)
.end


.sub 'delete'
  .param pmc argv
  .argc()

  # no arg delete does nothing
  .Unless(argc, {
  	.return('')
  })

  .local pmc splitNamespace, ns_root
  splitNamespace = get_root_global ['_tcl'], 'splitNamespace'
  ns_root = get_root_namespace ['tcl']

  $I0 = 0
delete_loop:
  if $I0 == argc goto return
  $S0 = argv[$I0]
  $P0 = splitNamespace($S0)
  $I1 = 0
  $I2 = elements $P0
  dec $I2
  $P1 = ns_root
loop:
  $S0 = $P0[$I1]
  if $I1 == $I2 goto end
  $P1 = $P1[$S0]
  inc $I1
  goto loop
end:
  delete $P1[$S0]
  inc $I0
  goto delete_loop

return:
  .return('')
.end

.sub 'exists'
  .param pmc argv
  .argc()

  .If(argc != 1, {
      die 'wrong # args: should be "namespace exists name"'
  })

  .local pmc colons, split, name
  colons = get_root_global ['_tcl'], 'colons'
  split  = get_root_global ['parrot'; 'PGE'; 'Util'], 'split'

  name = argv[0]

  $P0 = split(colons, name)
  $I0 = elements $P0
  if $I0 == 0 goto relative

  $S0 = $P0[0]
  if $S0 != '' goto relative
  $P1 = pop $P0
  goto get

relative:

get:
  .local pmc ns
  $I0 = 0
  $I1 = elements $P0
  ns = get_root_namespace ['tcl']
get_loop:
  if $I0 == $I1 goto get_end
  $P1 = $P0[$I0]
  ns  = ns[$P1]
  if null ns goto doesnt_exist
  inc $I0
  goto get_loop
get_end:
  .return(1)

doesnt_exist:
  .return(0)
.end

.sub 'qualifiers'
  .param pmc argv
  .argc()

  .If(argc != 1, {
      die 'wrong # args: should be "namespace qualifiers string"'
  })

  .local pmc p6r,match
  p6r = compreg 'PGE::Perl6Regex'
  match = p6r("(.*)\\:\\:+<-[:]>*$$")

  $S0 = argv[0]
  $P0 = match($S0)
  .If($P0, {
      $P1 = $P0[0]
      $S1 = $P1
      .return ($S1)
  })

  .return('')
.end

.sub 'tail'
  .param pmc argv
  .argc()

  .If(argc !=1, {
      die 'wrong # args: should be "namespace tail string"'
  })

  .local pmc p6r,match
  p6r= compreg 'PGE::Perl6Regex'
  match = p6r("\\:\\:+(<-[:]>*)$$")

  $S0 = argv[0]
  $P0 = match($S0)
  .If($P0, {
      $P2 = $P0[0]
      $S1 = $P2
      .return ($S1)
  })

  $P0 = argv[0]
  .return($P0)
.end

.sub 'eval'
  .param pmc argv
  .argc()

  .If(argc < 2, {
      die 'wrong # args: should be "namespace eval name arg ?arg...?"'
  })

  .local pmc call_chain
  call_chain      = get_root_global ['_tcl'], 'call_chain'
  .list(temp_call_chain)
  set_root_global ['_tcl'], 'call_chain', temp_call_chain

  .local pmc info_level
  info_level = get_root_global ['_tcl'], 'info_level'
  $P0 = clone argv
  unshift $P0, 'eval'
  unshift $P0, 'namespace'
  unshift info_level, $P0

  .local pmc ns, splitNamespace
  splitNamespace = get_root_global ['_tcl'], 'splitNamespace'

  ns = shift argv
  ns = splitNamespace(ns, 1)

  .local string namespace
  namespace = '[]'
  $I0 = elements ns
  if $I0 == 0 goto global_ns

  namespace = join "'; '", ns
  namespace = "['" . namespace
  namespace .= "']"

global_ns:
  .local pmc compileTcl, code
  compileTcl = get_root_global ['_tcl'], 'compileTcl'
  code     = new 'CodeString'
  $S0 = join ' ', argv
  ($S0, $S1) = compileTcl($S0, 'pir_only'=>1)
  $I0 = code.'unique'()
  .const 'Sub' ns_wrapper = 'namespace_wrapper'
  code.'emit'(ns_wrapper, namespace, $S0, $I0, $S1)

  .local pmc pir_compiler
  pir_compiler = compreg 'PIR'

  .TryCatch({
      $P0 = pir_compiler(code)
      $P0 = $P0()
      set_root_global ['_tcl'], 'call_chain', call_chain
      .return($P0)
  }, {
      set_root_global ['_tcl'], 'call_chain', call_chain
      .rethrow()
  })
.end

.sub 'children'
  .param pmc argv
  .argc()

  .local int has_pattern
  has_pattern = 0
 
  .If(argc > 2, {
      die 'wrong # args: should be "namespace children ?name? ?pattern?"'
  })
  if argc != 2 goto iterate

  .local string pattern_s
  .local pmc glob, pattern
  glob        = compreg 'Tcl::Glob'
  pattern_s   = argv[1]
  pattern     = glob.'compile'(pattern_s)
  has_pattern = 1

iterate:
  .list(list)

  .local pmc splitNamespace
  splitNamespace = get_root_global ['_tcl'], 'splitNamespace'

  .str(name, '')

  .If(argc, {
      name = argv[0]
  })

  .local pmc ns, ns_name
  ns_name  = splitNamespace(name, 1)

  .str(prefix,'')
  $I1 = elements ns_name
  .If($I1, {
      prefix = join '::', ns_name
      prefix .= '::'
  })
  prefix = '::' . prefix

  unshift ns_name, 'tcl'
  ns = get_root_namespace ns_name
  .If(null ns, {
      $S0 = 'unknown namespace "' . name
      $S0 .= '" in namespace children command'
      tcl_error $S0
  })

  .iter(ns)
loop:
  unless iterator goto end
  .str(ns_s, {shift iterator} )
  $P0 = ns[ns_s]
  $I0 = isa $P0, 'NameSpace'
  unless $I0 goto loop
  unless has_pattern goto is_namespace
  $P1 = pattern(ns_s)
  unless $P1 goto loop
is_namespace:
  ns_s = prefix . ns_s
  push list, ns_s
  goto loop
end:

  .return(list)
.end

.sub 'code'
  .param pmc argv
  .argc()

  .If(argc!=1, {
      die 'wrong # args: should be "namespace code arg"' 
  })

  .local string script, current_ns, retval
  script = shift argv

  .local string current_ns
  $P1 = new 'TclList'
  current_ns = 'current'($P1)

  retval = "namespace inscope "
  retval .= current_ns
  retval .= " {" 
  retval .= script
  retval .= "}"
  .return (script)
.end

.sub 'import'
  .param pmc argv
  .argc()

  argc = argv
  if argc == 0 goto done
  # ignore -force for now (assume it)
  $S0 = argv[0]
  if $S0 != '-force' goto done_args
  $P0 = shift argv
done_args:
  .local pmc splitNamespace
  splitNamespace  = get_root_global ['_tcl'], 'splitNamespace'

  .local pmc globber
  globber = compreg 'Tcl::Glob'

  .local pmc ns_root
  ns_root = get_root_namespace ['tcl']

  .iter(argv)
begin_argv:
  unless iterator goto done_argv
  $P0 = shift iterator

  .local pmc ns
  ns = splitNamespace($P0)

  .local string pattern
  pattern = pop ns
  pattern = '&' . pattern # all our public procs are prefixed with &

  .local pmc namespace
  namespace = ns_root

  .local pmc ns_iterator
  ns_iterator = iter ns
begin_ns_walk:
  unless ns_iterator goto done_ns_walk
  $S0 = shift ns_iterator
  namespace = namespace[$S0]
  if null namespace goto end_ns_loop

  goto begin_ns_walk
done_ns_walk:

  .local pmc rule, match
  rule = globber.'compile'(pattern)

  ns_iterator = iter namespace
  .local string proc_name

begin_ns_loop:
  unless ns_iterator goto end_ns_loop
  proc_name = shift ns_iterator

  match = rule(proc_name)
  unless match goto begin_ns_loop

  $P1 = namespace[proc_name]
  ns_root[proc_name] = $P1 # XXX Always imports to main, not current namespace

  goto begin_ns_loop
end_ns_loop:

  goto begin_argv
done_argv:

done:
  .return ('')
.end

.sub 'inscope'
  .param pmc argv
  .tailcall eval(argv)
.end

#XXX complete hack to get tcltest working...
.sub 'origin'
  .param pmc argv

  $S0 = shift argv
  $S0 = "::tcltest::" . $S0
  .return ($S0)
.end

.sub 'parent'
  .param pmc argv
  .argc()

  .str(name, '')

  .If(argc > 1, {
      die 'wrong # args: should be "namespace parent ?name?"'
  })

  .If (argc, {
      name = argv[0]
  })

  .local pmc splitNamespace
  splitNamespace = get_root_global ['_tcl'], 'splitNamespace'

  .local pmc ns
  ns  = splitNamespace(name)

  .TryCatch({
      $S0 = pop ns
      $S0 = join '::', ns
      $S0 = '::' . $S0
      .return($S0)
  }, {
      .return('')
  })
.end

.sub 'which'
  .param pmc argv

  .local string cmd

  .DoWhile({
      cmd = shift argv
  },{cmd == '-command'})

  # This should use the same logic as our command dispatch. 
  $S1 = "&" . cmd 
  $P1 = get_root_global ['tcl'], $S1
  .If(null $P1, {
      .return ('')
  })
  $S0 = '::' . cmd
  .return($S0)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
