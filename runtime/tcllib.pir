=head1 tcllib

This file contains all the PIR necessary to setup the C<tcl> and
C<_tcl> namespaces. These namespaces can then be used
by our own C<tcl.pir> to setup a tclsh-like interpreter, or to allow
other PIR programs to access procedures in our own namespaces, also
providing a compreg-compatible method.

=cut

.HLL 'parrot'

.loadlib 'tcl_ops'
.include 'hllmacros.pir'  # from parrot
.include 'src/macros.pir'
.include 'cclass.pasm'

.HLL '_tcl'

.sub 'mappings' :anon :load
  .local pmc interp
  .local pmc core_int, tclint
  .local pmc core_num, tclfloat
  .local pmc core_string, tclstring

  interp = getinterp

  core_int = get_class 'Integer'
  core_num = get_class 'Float'
  core_string = get_class 'String'

  tclint    = get_class 'TclInt'
  tclfloat  = get_class 'TclFloat'
  tclstring = get_class 'TclString'

  interp.'hll_map'(core_int, tclint)
  interp.'hll_map'(core_num, tclfloat)
  interp.'hll_map'(core_string, tclstring)
.end

# class files
.include 'src/class/string.pir'
.include 'src/class/tclarray.pir'
.include 'src/class/tclconst.pir'
.include 'src/class/tcldict.pir'
.include 'src/class/tcllist.pir'
.include 'src/class/tclproc.pir'
.include 'src/class/tclstring.pir'
.include 'src/class/tracearray.pir'

.HLL 'parrot'
.namespace [ 'TclExpr'; 'PAST'; 'Grammar' ]
.include 'src/grammar/expr/pge2past.pir'

.namespace [ 'TclExpr'; 'PIR'; 'Grammar' ]
.include 'src/grammar/expr/past2pir.pir'

.include 'src/grammar/expr/past.pir'

# all the builtin commands (HLL: Tcl - loads 'tcl_group')
.include 'runtime/builtins.pir'

# library files (HLL: _tcl)
.include 'runtime/compilers.pir'
.include 'runtime/conversions.pir'
.include 'runtime/variables.pir'
.include 'runtime/options.pir'

# create the 'tcl' namespace -- see RT #39852
# https://rt.perl.org/rt3/Ticket/Display.html?id=39852
.HLL 'tcl'
.namespace ['tcl']
.sub foo
  .return()
.end

.HLL '_tcl'
.namespace []

.sub prepare_lib :load :anon
  # Load any dependant libraries.
  load_bytecode 'Getopt/Obj.pbc'
  load_bytecode 'PGE.pbc'
  load_bytecode 'PGE/Text.pbc'
  load_bytecode 'PGE/Util.pbc'
  load_bytecode 'TGE.pbc'
  load_bytecode 'Tcl/Glob.pir'

  # Expose Environment variables.
  .local pmc env,tcl_env,iterator
  env = new 'Env'
  tcl_env = new 'TclArray'

  iterator = iter env

  .local string key,value
env_loop:
  unless iterator goto env_loop_done
  key = shift iterator
  value = env[key]
  tcl_env[key] = value

  goto env_loop

env_loop_done:
  set_root_global ['tcl'], '$env', tcl_env

  # set tcl_interactive
  push_eh non_interactive
    $P1 = get_root_global ['tcl'], '$tcl_interactive'
  pop_eh
  goto set_tcl_library
 non_interactive:
  $P1 = box 0
  set_root_global ['tcl'], '$tcl_interactive', $P1

 set_tcl_library:
  # Set tcl_library:
  .local pmc    interp, config
  .local string slash
  interp = getinterp
  .include 'iglobals.pasm'

  config = interp[.IGLOBALS_CONFIG_HASH]
  # Find it out of partcl's build dir.
  $S0 .= 'library'
  .local pmc tcl_library
  tcl_library = box $S0
  set_root_global ['tcl'], '$tcl_library', tcl_library

  # get the name of the executable
  $P1 = interp[.IGLOBALS_EXECUTABLE]
  set_root_global [ '_tcl' ], 'nameofexecutable', $P1

  # set tcl_platform
  $P1 = new 'TclArray'
  $P1['platform'] = 'unix'
  .local string slash
  slash = config['slash']
  if slash == "\\" goto win
  $P1['platform'] = 'unix'
  goto got_platform 
win:
  $P1['platform'] = 'windows'
got_platform:
  set_root_global ['tcl'], '$tcl_platform', $P1
  $I1 = config['bigendian']
  if $I1 goto big_endian
  $P1['byteOrder'] = 'littleEndian'
  goto done_endian
 big_endian:
  $P1['byteOrder'] = 'bigEndian'

 done_endian:
  $I1 = config['intsize']
  $P1['wordSize'] = $I1

  $S1 = config['osname']
  $P1['os'] = $S1

  $S1 = config['cpuarch'] # XXX first approximation
  $P1['machine'] = $S1

  $P1['osVersion'] = 8    # XXX extract from parrot

  # Set default precision.
  $P1 = box 0
  set_root_global ['tcl'], '$tcl_precision', $P1

  $P1 = root_new ['parrot'; 'TclList']
  set_global 'info_level', $P1

  $P1 = root_new ['parrot'; 'TclList']
  set_global 'events', $P1

  # Global variable initialization

   #version info
  $P0 = box '8.5.6'
  set_root_global ['tcl'], '$tcl_patchLevel', $P0
  $P0 = box '8.5'
  set_root_global ['tcl'], '$tcl_version', $P0

  #error information
  $P0 = box 'NONE'
  set_root_global ['tcl'], '$errorCode', $P0
  $P0 = box ''
  set_root_global ['tcl'], '$errorInfo', $P0

  # Setup the default channelIds
  $P1 = new 'TclArray'
  $P2 = getstdin
  $P1['stdin'] = $P2
  $P2 = getstdout
  $P1['stdout'] = $P2
  $P2 = getstderr
  $P1['stderr'] = $P2
  set_global 'channels', $P1

  # Setup the id # for channels..
  $P1 = box 1
  set_global 'next_channel_id', $P1

  # call chain of lex pads (for upvar and uplevel)
  $P1 = root_new ['parrot'; 'TclList']
  set_global 'call_chain', $P1

  # the regex used for namespaces
  .local pmc p6rule, colons
  p6rule = compreg 'PGE::Perl6Regex'
  colons = p6rule('\:\:+')
  set_hll_global 'colons', colons

  # register the TCL compiler.
  $P1 = get_root_global ['_tcl'], 'compileTcl'
  compreg 'TCL', $P1

  # Setup a global to keep a unique id for compiled subs.
  $P1 = box 0
  set_global 'compiled_num', $P1
.end

.HLL 'parrot'
.include 'src/grammar/expr/expression.pir'
.include 'src/grammar/expr/parse.pir'
.include 'src/grammar/expr/functions.pir'
.include 'src/grammar/expr/operators.pir'

.HLL 'tcl'
.namespace [ 'tcl'; 'mathop' ]
.include 'src/mathops.pir'

# Load the standard library
.HLL 'tcl'
.namespace []

.sub load_stdlib :load :anon
  .include 'iglobals.pasm'
  .local pmc interp
  interp = getinterp
  $P1 = interp[.IGLOBALS_CONFIG_HASH]

  .local string slash
  slash = $P1['slash']
  $P2 = $P1['slash']
  set_root_global ['_tcl'], 'slash', $P2
.end

.HLL 'parrot'
.namespace ['Tcl';'Compiler']

.sub '' :anon :load
    .local pmc ns, tclass, compiler
    ns = get_hll_namespace ['Tcl';'Compiler']
    tclass = newclass ns
    compiler = new tclass
    compreg 'tcl', compiler
.end

.sub 'load_library' :method
    .param pmc name
    .param pmc extra :named :slurpy

    .local pmc ct, lit
    .local string filename

    filename = join '/', name
    filename = concat filename, '.tcl'
    ct = get_root_global ['_tcl'], 'compileTcl'
    $P0 = get_hll_namespace
    lit = $P0['load_init_tcl']
    $P0 = root_new ['parrot';'TclString']
    $P0 = filename
    set_root_global ['_tcl'], '$script', $P0
   .local string contents
   $P99 = open filename, 'r'
   contents = $P99.'readall'()

    lit()
    $P2 = ct(contents, 'bsnl' => 1)
    $P2()

    .local pmc library, sourcens, symns, nsiter
    .local string item, titem
    library = root_new ['parrot';'Hash']
    sourcens = get_hll_namespace name
    library['name'] = name
    library['namespace'] = sourcens
    symns = root_new ['parrot';'NameSpace']
    nsiter = iter sourcens
  loop:
    unless nsiter goto loop_end
    item = shift nsiter
    $S0 = substr item, 0, 1
    titem = concat item, ''
    eq $S0, '&', trim
    eq $S0, '$', trim
    goto no_trim
  trim:
    substr titem, 0, 1, ''
  no_trim:
    $P0 = sourcens[item]
    symns[titem] = $P0
    goto loop
  loop_end:
    $P0 = root_new ['parrot';'Hash']
    $P0['ALL'] = symns
    $P0['DEFAULT'] = symns
    library['symbols'] = $P0
    .return (library)
.end

.HLL 'parrot'
.namespace []

.sub hack_grammar :load :anon
  # Override whitespace parsing in expression's optable
  $P0 = get_hll_global ['TclExpr'; 'Grammar'], '$optable'
  $P1 = get_hll_global ['TclExpr'; 'Grammar'], 'exprws'
  setattribute $P0, '&!ws', $P1

  #  Override recursion limit
  $P0 = getinterp
  $P0.'recursion_limit'(10000)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
