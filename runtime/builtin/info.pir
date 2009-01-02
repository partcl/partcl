.HLL 'Tcl'
.namespace []

.sub '&info'
  .param pmc argv :slurpy

  .local int argc
  argc = elements argv
  unless argc goto bad_args

  .local string subcommand_name
  subcommand_name = shift argv

  .local pmc options
  options = get_root_global ['_tcl'; 'helpers'; 'info'], 'options'

  .local pmc select_option
  select_option  = get_root_global ['_tcl'], 'select_option'

  .local string canonical_subcommand
  canonical_subcommand = select_option(options, subcommand_name)

  .local pmc subcommand_proc
  null subcommand_proc

  subcommand_proc = get_root_global ['_tcl';'helpers';'info'], canonical_subcommand
  if null subcommand_proc goto bad_subcommand

  .tailcall subcommand_proc(argv)

bad_subcommand:
  .return ('') # once all commands are implemented, remove this...

 bad_args:
  die 'wrong # args: should be "info subcommand ?argument ...?"'
.end

.HLL '_Tcl'
.namespace [ 'helpers'; 'info' ]

.sub 'args'
  .param pmc argv

  .local int argc
  argc = elements argv
  if argc != 1 goto bad_args

  .local pmc retval

  .local string procname
  procname = shift argv

  .local pmc splitNamespace
  splitNamespace = get_root_global ['_tcl'], 'splitNamespace'

  .local pmc    ns
  .local string name
  ns   = splitNamespace(procname)
  name = pop ns
  name = '&' . name

  unshift ns, 'tcl'
  $P1 = get_root_global ns, name
  if null $P1 goto no_args

  $P2 = getattribute $P1, 'args'
  if null $P2 goto no_args
  .return($P2)

  .return($P2)

no_args:
  $S0 = '"'
  $S0 .= procname
  $S0 .= "\" isn't a procedure"
  die $S0

bad_args:
  die 'wrong # args: should be "info args procname"'
.end

.sub 'body'
  .param pmc argv

  .local int argc
  argc = elements argv
  if argc != 1 goto bad_args

  .local string procname
  procname = argv[0]

  .local pmc splitNamespace
  splitNamespace = get_root_global ['_tcl'], 'splitNamespace'

  .local pmc    ns
  .local string name
  ns   = splitNamespace(procname)
  name = pop ns
  name = '&' . name

  unshift ns, 'tcl'
  $P1 = get_root_global ns, name
  if null $P1 goto no_body
  $P2 = getattribute $P1, 'HLL_source'
  if null $P2 goto no_body
  .return($P2)

no_body:
  $S0 = '"'
  $S0 .= procname
  $S0 .= "\" isn't a procedure"
  die $S0

bad_args:
  die 'wrong # args: should be "info body procname"'
.end

.sub 'complete'
  .param pmc argv
  .local int argc
  argc = elements argv
  if argc != 1 goto bad_args

  .local pmc body
  body = argv[0]
  push_eh nope
    $P1 = compileTcl(body)
  pop_eh
  .return(1)

nope:
  .catch()
  $S0 = exception
  if $S0 == 'missing close-brace'   goto fail
  if $S0 == 'missing close-bracket' goto fail
  if $S0 == 'missing "'             goto fail
  .rethrow()

fail:
  .return(0)

bad_args:
  die 'wrong # args: should be "info complete command"'
.end

.sub 'default'
  .param pmc argv

  .local int argc
  argc = elements argv
  if argc != 3 goto bad_args

  .local pmc retval

  .local string procname, argname, varname
  procname = argv[0]
  argname  = argv[1]
  varname  = argv[2]

  .local pmc setVar
  setVar = get_root_global ['_tcl'], 'setVar'

  .local pmc splitNamespace
  splitNamespace = get_root_global ['_tcl'], 'splitNamespace'

  .local pmc    ns
  .local string name
  ns   = splitNamespace(procname)
  name = pop ns
  name = '&' . name

  unshift ns, 'tcl'
  $P1 = get_root_global ns, name
  if null $P1 goto not_proc

  $P2 = getattribute $P1, 'defaults'
  $P9 = getattribute $P1, 'args'
  if null $P2 goto check_arg

  $P3 = $P2[argname]
  if_null $P3, check_arg
  push_eh error_on_set
    setVar(varname, $P3)
  pop_eh

  # store in variable
  .return (1)

check_arg:
  # there's no default. is there even an arg?
  $P3 = toList($P9)
  $P4 = iter $P3
loop:
  unless $P4 goto not_argument
  $S1 = shift $P4
  if $S1==argname goto no_default
  goto loop

not_argument:
  $S0 = 'procedure "'
  $S0 .= procname
  $S0 .= "\" doesn't have an argument \""
  $S0 .= argname
  $S0 .= '"'
  die $S0

no_default:
  push_eh error_on_set
    setVar(varname, '')
  pop_eh
  .return (0)

error_on_set:
  .catch()
  $S0 = "couldn't store default value in variable \""
  $S0 .= varname
  $S0 .= '"'
  die $S0

not_proc:
  $S0 = '"'
  $S0 .= procname
  $S0 .= "\" isn't a procedure"
  die $S0


bad_args:
  die 'wrong # args: should be "info default procname arg varname"'
.end


.sub 'functions'
  .param pmc argv

  .local int argc
  argc = elements argv
  if argc > 1 goto bad_args

  .local pmc mathfunc,iterator,retval

  mathfunc = get_root_namespace ['tcl'; 'tcl'; 'mathfunc']
  iterator = iter mathfunc
  retval = new 'TclList'

  .local pmc globber,rule,match
  globber = compreg 'Tcl::Glob'
  if argc == 1 goto got_glob
  $S1 = '&*'
  goto compile
got_glob:
  $S1 = argv[0]
  $S1 = '&' . $S1
compile:
  rule = globber.'compile'($S1)
loop:
  unless iterator goto end
  $S0 = shift iterator
  $P0 = mathfunc[$S0]
  match = rule($S0)
  unless match goto loop
  $S1 = substr $S0, 1
  push retval, $S1
  goto loop
end:
  .return(retval)

bad_args:
  die 'wrong # args: should be "info functions ?pattern?"'
.end

.sub 'commands'
    .param pmc argv

    .local int argc
    argc = elements argv
    if argc > 1 goto bad_args
    .local pmc matching
    null matching
    if argc ==0 goto done_setup

    $P1 = compreg 'Tcl::Glob'
    .local string pattern
    pattern = argv[0]

    # cheat and just remove a leading "::" for now
    $S0 = substr pattern, 0, 2
    if $S0 != "::" goto create_glob
    $S0 = substr pattern, 0, 2, ''

  create_glob:
    matching = $P1.'compile'(pattern)

  done_setup:
    .local pmc result
    result = new 'TclList'

    .local pmc ns
    ns = get_root_global 'tcl'

    .local pmc iterator
    iterator = iter ns
  iter_loop:
     unless iterator goto iter_loop_end
     $S1 = shift iterator
     $S2 = substr $S1, 0, 1
     unless $S2 == '&' goto iter_loop
     $S1 = substr $S1, 1
     if_null matching, add_result
     $P2 = matching($S1)
     unless $P2 goto iter_loop
  add_result:
     push result, $S1
     goto iter_loop
  iter_loop_end:

    .return(result)

  bad_args:
    die 'wrong # args: should be "info commands ?pattern?"'

.end

.sub 'exists'
  .param pmc argv

  .local int argc
  argc = elements argv
  if argc != 1 goto bad_args

  .local string varname
  varname = argv[0]

  .local pmc readVar, found_var
  readVar  = get_root_global ['_tcl'], 'readVar'
  push_eh not_found
    found_var = readVar(varname)
  pop_eh
  .return (1)

not_found:
  .catch()
  .return (0)

bad_args:
  die 'wrong # args: should be "info exists varName"'
.end

#
# Should probably just write this help sub /in tcl/
#
.sub 'tclversion'
  .param pmc argv

  .local int argc
  argc = elements argv

  if argc != 0 goto bad_args

  $P1 = get_root_global ['tcl'], '$tcl_version'
  $I0 = isa $P1, 'Undef'
  if $I0 goto no_var
  .return($P1)

no_var:
  die "can't read \"tcl_version\": no such variable"

bad_args:
  die 'wrong # args: should be "info tclversion"'

.end

.sub 'patchlevel'
  .param pmc argv

  .local int argc
  argc = elements argv

  if argc != 0 goto bad_args

  .local pmc read
  read = get_root_global ['_tcl'], 'readVar'
  .tailcall read('tcl_patchLevel')

bad_args:
  die 'wrong # args: should be "info patchlevel"'

.end

.sub 'library'
  .param pmc argv

  .local int argc
  argc = elements argv

  if argc != 0 goto bad_args

  $P1 = get_root_global ['tcl'], '$tcl_library'
  $S0 = $P1
  if $S0 == '' goto empty
  .return($P1)

empty:
  die "no library has been specified for Tcl"

bad_args:
  die 'wrong # args: should be "info library"'

.end

.sub 'vars'
  .param pmc argv

  .local int argc
  argc = elements argv

  if argc == 0 goto iterate
  if argc > 1  goto bad_args

iterate:
  .local pmc call_chain, lexpad
  call_chain = get_root_global ['_tcl'], 'call_chain'
  $I1 = elements call_chain
  if $I1 == 0 goto get_globals

  lexpad     = call_chain[-1]

  .local pmc    iterator, retval
  .local string elem
  iterator = iter lexpad
  retval = new 'TclList'
loop:
  unless iterator goto end
  elem = shift iterator
  $S0 = substr elem, 0, 1, ''
  unless $S0 == '$' goto loop
  push retval, elem
  goto loop
end:
  .return(retval)

bad_args:
  die 'wrong # args: should be "info vars ?pattern?"'

get_globals:
  .tailcall 'globals'(argv)
.end

.sub 'level'
  .param pmc argv

  .local int argc
  argc = elements argv

  if argc == 0 goto current_level
  if argc == 1 goto find_level

  die 'wrong # args: should be "info level ?number?"'

current_level:
  .local pmc call_chain
  call_chain = get_root_global ['_tcl'], 'call_chain'
  $I0 = elements call_chain
  .return($I0)

find_level:
  .local pmc toInteger, getCallLevel
  toInteger    = get_root_global ['_tcl'], 'toInteger'
  getCallLevel = get_root_global ['_tcl'], 'getCallLevel'

  .local pmc level
  level = shift argv
  level = toInteger(level)
  if level >= 0 goto find_info_level
  level = getCallLevel(level)
  .return(level)

find_info_level:
  .local pmc info_level
  info_level = get_root_global ['_tcl'], 'info_level'
  $P0 = info_level[level]
  .return($P0)
.end

.sub 'globals'
  .param pmc argv

  .local int argc
  argc = elements argv
  if argc > 1 goto bad_args

  .local pmc ns,iterator,retval

  ns = get_root_namespace ['tcl']
  iterator = iter ns
  retval = new 'TclList'

  .local pmc globber,rule,match
  globber = compreg 'Tcl::Glob'
  if argc == 1 goto got_glob
  $S1 = "$*"
  goto compile
got_glob:
  $S1 = argv[0]
  $S1 = '$' . $S1
compile:
  rule = globber.'compile'($S1)
loop:
  unless iterator goto end
  $S0 = shift iterator
  $P0 = ns[$S0]
  match = rule($S0)
  unless match goto loop
  $S1 = substr $S0, 1
  push retval, $S1
  goto loop
end:
  .return(retval)

bad_args:
  die 'wrong # args: should be "info globals ?pattern?"'
.end

.sub 'script'
  .param pmc argv
  $P0 = get_root_global ['_tcl'], '$script'
  .return($P0)
.end

# RT#40740: stub
# sharedlibextension - should be able to pull this from parrot config.
.sub 'sharedlibextension'
  .param pmc argv
  .return(0)
.end

# RT#40741: stub
.sub 'nameofexecutable'
  .param pmc argv
  .local int argc
  argc = elements argv
  if argc goto bad_args
  $P1 = get_root_global ['_tcl'], 'nameofexecutable'
  .return($P1)
bad_args:
  die 'wrong # args: should be "info nameofexecutable"'
.end

# RT#40742: stub
.sub 'loaded'
  .param pmc argv
  .return(0)
.end

# RT#40744: stub
.sub 'cmdcount'
  .param pmc argv
  .return(0)
.end

.sub 'anon' :anon :load
  .local pmc options
  options = new 'TclList'
  push options, 'args'
  push options, 'body'
  push options, 'cmdcount'
  push options, 'commands'
  push options, 'complete'
  push options, 'default'
  push options, 'exists'
  push options, 'frame'
  push options, 'functions'
  push options, 'globals'
  push options, 'hostname'
  push options, 'level'
  push options, 'library'
  push options, 'loaded'
  push options, 'locals'
  push options, 'nameofexecutable'
  push options, 'patchlevel'
  push options, 'procs'
  push options, 'script'
  push options, 'sharedlibextension'
  push options, 'tclversion'
  push options, 'vars'

  set_root_global ['_tcl'; 'helpers'; 'info'], 'options', options
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
