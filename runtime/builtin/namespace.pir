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
    .prof('tcl;namespace_options')

    .local pmc opts
    opts = split ' ', 'children code current delete ensemble eval exists export forget import inscope origin parent path qualifiers tail unknown upvar which'

    .return(opts)
.end

.sub 'namespace_wrapper' :anon :immediate
    .prof('tcl;namespace_wrapper')

    .return(<<'END_PIR')
.HLL 'tcl'
.namespace %0
# src/compiler.pir :: pir_compiler (2)
.sub compiled_tcl_sub_%2
  .prof("tcl;%0;compiled_tcl_sub_%2")
  %1
  .return(%3)
.end
END_PIR

.end

.sub '&namespace'
    .param pmc argv :slurpy

    .prof('tcl;&namespace')

    .int(argc, elements argv)
    .Unless(argc, {
        die 'wrong # args: should be "namespace subcommand ?arg ...?"'
    })

  .local string subcommand_name
  subcommand_name = shift argv

    .const 'Sub' options = 'namespace_options'

  .local pmc select_option
  select_option  = get_root_global ['_tcl'], 'select_option'

  .local string canonical_subcommand
  canonical_subcommand = select_option(options, subcommand_name)

  .local pmc subcommand_proc
  null subcommand_proc

  subcommand_proc = get_root_global ['_tcl';'helpers';'namespace'], canonical_subcommand
  if null subcommand_proc goto bad_args

  .tailcall subcommand_proc(argv)

bad_args:
  .return ('') # once all commands are implemented, remove this...
.end

.HLL '_tcl'
.namespace [ 'helpers'; 'namespace' ]

.sub 'current'
  .param pmc argv

  .prof('_tcl;helpers;namespace;current')

  .local int argc
  argc = elements argv

  .If(argc, {
      die 'wrong # args: should be "namespace current"'
  })

  .local pmc ns, splitNamespace
  splitNamespace = get_root_global ['_tcl'], 'splitNamespace'
  ns  = splitNamespace('')
  $S0 = join '::', ns
  $S0 = '::' . $S0
  .return($S0)
.end

.sub 'delete'
  .param pmc argv

  .prof('_tcl;helpers;namespace;delete')

  .local int argc
  argc = elements argv

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

  .prof('_tcl;helpers;namespace;exists')

  .local int argc
  argc = elements argv
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

  .prof('_tcl;helpers;namespace;qualifiers')

  .local int argc
  argc = elements argv

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

  $S0 = argv[0]
  .return($S0)
.end

.sub 'tail'
  .param pmc argv

  .prof('_tcl;helpers;namespace;tail')

  .local int argc
  argc = elements argv
  .If(argc !=1, {
      die 'wrong # args: should be "namespace tail string"'
  })

  .local pmc p6r,match
  p6r= compreg 'PGE::Perl6Regex'
  match = p6r("\\:\\:+(<-[:]>)$$")

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

  .prof('_tcl;helpers;namespace;eval')

  .local int argc
  argc = elements argv
  .If(argc < 2, {
      die 'wrong # args: should be "namespace eval name arg ?arg...?"'
  })

  .local pmc call_chain, temp_call_chain
  call_chain      = get_root_global ['_tcl'], 'call_chain'
  temp_call_chain = root_new ['parrot'; 'TclList']
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
  code     = root_new ['parrot'; 'CodeString']
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

  .prof('_tcl;helpers;namespace;children')

  .local int has_pattern
  has_pattern = 0

  .local int argc
  argc = elements argv
  .If(argc > 2, {
      die 'wrong # args: should be "namespace children ?name? ?pattern?"'
  })
  if argc != 2 goto iterate

  .local pmc glob, pattern
  glob        = compreg 'Tcl::Glob'
  pattern     = argv[1]
  pattern     = glob.'compile'(pattern)
  has_pattern = 1

iterate:
  .local pmc list
  list = root_new ['parrot'; 'TclList']

  .local pmc splitNamespace, ns, ns_name
  .local string name
  splitNamespace = get_root_global ['_tcl'], 'splitNamespace'

  name = ''
  .If(argc, {
      name = argv[0]
  })

  ns_name  = splitNamespace(name, 1)

  unshift ns_name, 'tcl'
  ns = get_root_namespace ns_name
  .If(null ns, {
      $S0 = argv[0]
      $S0 = 'unknown namespace "' . $S0
      $S0 = $S0 . '" in namespace children command'
      die $S0
  })

  .local pmc iterator
  iterator = iter ns
loop:
  unless iterator goto end
  $S0 = shift iterator
  $P0 = ns[$S0]
  $I0 = isa $P0, 'NameSpace'
  unless $I0 goto loop
  $P0 = $P0.'get_name'()
  $S0 = shift $P0 # get rid of 'tcl'
  $S0 = join '::', $P0
  $S0 = '::' . $S0
  $P0 = box $S0
  unless has_pattern goto is_namespace
  $P1 = pattern($P0)
  unless $P1 goto loop
is_namespace:
  push list, $P0
  goto loop
end:

  .return(list)
.end

.sub 'code'
  .param pmc argv

  .prof('_tcl;helpers;namespace;code')

  .local string script, current_ns, retval
  script = shift argv

  .local string current_ns
  $P1 = root_new ['parrot'; 'TclList']
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
  .prof('_tcl;helpers;namespace;import')
  .local int argc
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

  .local pmc iterator
  iterator = iter argv
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
  .prof('_tcl;helpers;namespace;inscope')
  .tailcall eval(argv)
.end

#XXX complete hack to get tcltest working...
.sub 'origin'
  .param pmc argv
  .prof('_tcl;helpers;namespace;origin')

  $S0 = shift argv
  $S0 = "::tcltest::" . $S0
  .return ($S0)
.end

.sub 'parent'
  .param pmc argv

  .prof('_tcl;helpers;namespace;parent')
  .local int argc
  argc = elements argv

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

  .prof('_tcl;helpers;namespace;which')
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
