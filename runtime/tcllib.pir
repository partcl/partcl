=head1 tcllib

This file contains all the PIR necessary to setup the basic C<Tcl>,
C<_Tcl>, and C<_TclWord> namespaces. These namespaces can then be used
by our own C<tcl.pir> to setup a tclsh-like interpreter, or to allow
other PIR programs to access procedures in our own namespaces, also
providing a compreg-compatible method.

=cut

.HLL '_tcl'

.sub 'mappings' :anon :init
  .local pmc interp
  .local pmc core_int, tclint
  .local pmc core_num, tclfloat
  .local pmc core_string, tclstring

  interp = getinterp

  core_int = get_class 'Integer'
  core_num = get_class 'Float'
  core_string = get_class 'Float'

  tclint    = get_class 'TclInt'
  tclfloat  = get_class 'TclFloat'
  tclstring = get_class 'TclString'

  interp.'hll_map'(core_int, tclint)
  interp.'hll_map'(core_num, tclfloat)
  interp.'hll_map'(core_string, tclstring)
.end

.HLL 'parrot'

.loadlib 'tcl_ops'
.include 'src/macros.pir'
.include 'cclass.pasm'

.namespace [ 'TclExpr'; 'PAST'; 'Grammar' ]
.include 'src/grammar/expr/pge2past.pir'

.namespace [ 'TclExpr'; 'PIR'; 'Grammar' ]
.include 'src/grammar/expr/past2pir.pir'

.include 'src/grammar/expr/past.pir'

# all the builtin commands (HLL: Tcl - loads 'tcl_group')
.include 'runtime/builtins.pir'

# library files (HLL: _Tcl)
.include 'runtime/conversions.pir'
.include 'runtime/string_to_list.pir'
.include 'runtime/variables.pir'
.include 'runtime/options.pir'

# class files (HLL: _Tcl)
.include 'src/class/tclarray.pir'
.include 'src/class/tclconst.pir'
.include 'src/class/tclproc.pir'
.include 'src/class/tracearray.pir'

# create the 'tcl' namespace -- see RT #39852
# https://rt.perl.org/rt3/Ticket/Display.html?id=39852
.HLL 'Tcl'
.namespace ['tcl']
.sub foo
  .return()
.end

.HLL '_Tcl'
.namespace []

.sub load_macros :load :anon
  $P0 = compreg 'PIR'
  $P0 = $P0(".sub main\n.include 'src/macros.pir'\n.end")
  $P0()
.end

.sub prepare_lib :load :anon

  # Load any dependant libraries.
  load_bytecode 'Getopt/Obj.pbc'
  load_bytecode 'PGE.pbc'
  load_bytecode 'PGE/Text.pbc'
  load_bytecode 'PGE/Util.pbc'
  load_bytecode 'TGE.pbc'

  load_bytecode 'Tcl/Glob.pbc'

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
  $S0 = config['build_dir']
  slash = config['slash']
  $S0 .= slash
  $S0 .= 'languages'
  $S0 .= slash
  $S0 .= 'tcl'
  $S0 .= slash
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

  # keep track of names of file types.
  .local pmc filetypes
  filetypes = new 'TclArray'
  filetypes[0o060000] = 'blockSpecial'
  filetypes[0o020000] = 'characterSpecial'
  filetypes[0o040000] = 'directory'
  filetypes[0o010000] = 'fifo'
  filetypes[0o100000] = 'file'
  filetypes[0o120000] = 'link'
  filetypes[0o140000] = 'socket'

   set_global 'filetypes', filetypes

   .local pmc binary_types
   binary_types = new 'TclArray'
   binary_types['a'] = 1
   binary_types['A'] = 1
   binary_types['b'] = 1
   binary_types['B'] = 1
   binary_types['h'] = 1
   binary_types['H'] = 1
   binary_types['c'] = 1
   binary_types['s'] = 1
   binary_types['S'] = 1
   binary_types['i'] = 1
   binary_types['I'] = 1
   binary_types['w'] = 1
   binary_types['W'] = 1
   binary_types['f'] = 1
   binary_types['d'] = 1
   binary_types['x'] = 1
   binary_types['X'] = 1
   binary_types['@'] = 1

   set_global 'binary_types', binary_types

  # Eventually, we'll need to register MMD for the various Tcl PMCs
  # (Presuming we don't do this from the .pmc definitions.)

  $P1 = new 'TclList'
  set_global 'info_level', $P1

  $P1 = new 'TclList'
  set_global 'events', $P1

  # Global variable initialization

   #version info
  $P0 = box '0.1'
  set_root_global ['tcl'], '$tcl_patchLevel', $P0
  $P0 = box '0.1'
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
  $P1 = new 'TclList'
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
.HLL 'Tcl'
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
