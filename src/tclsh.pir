#
# _main
#
# Setup the information the interpreter needs to run,
# then parse and interpret/compile the tcl code we were passed.

.loadlib 'tcl_ops'
.loadlib 'bit_ops'        # from parrot
.loadlib 'io_ops'         # from parrot
.loadlib 'trans_ops'      # from parrot


.include 'hllmacros.pir'

.HLL 'tcl'
.loadlib 'tcl_group'

.include 'src/returncodes.pasm'
.include 'src/macros.pir'

.macro set_tcl_argv()
  .argc()
  .local pmc tcl_argv
  tcl_argv = new 'TclList'
  .local int ii,jj
  ii = 1
  jj = 0
.label $argv_loop:
  if ii >= argc  goto .$argv_loop_done
  $P0 = argv[ii]
  tcl_argv[jj] = $P0
  inc ii
  inc jj
  goto .$argv_loop
.label $argv_loop_done:
  set_global '$argv', tcl_argv
.endm

.sub _main :main
  .param pmc argv

  load_bytecode 'runtime/tcllib.pbc'

  .local pmc retval
  .local string mode,contents,filename
  .local int retcode

  .local pmc tcl_interactive
  tcl_interactive = box 0
  set_global '$tcl_interactive', tcl_interactive

  .local pmc compileTcl
  compileTcl = get_root_global ['_tcl'], 'compileTcl'

  .local pmc get_options
  get_options = new ['Getopt'; 'Obj']
  push get_options, 'e=s'
  push get_options, 'q'

  .local pmc opt
  $S0 = shift argv   # drop "tcl.pbc"
  opt = get_options.'get_options'(argv)

  .int(quick, {defined opt['q']})
  .IfElse(quick, {
      $P0 = box 1
   }, {
      $P0 = box 0
   })
   set_root_global ['_tcl'], '$quick', $P0

  .local int execute
  execute   = defined opt['e']

  if execute goto oneliner

  .argc()
  if argc >0 goto open_file

  tcl_interactive = 1

  # If no file was specified, read from stdin.
  load_init_tcl()

  .local string input_line
  .local pmc STDIN
  STDIN = getstdin

  input_line = ''

  .local int level
  level = 1
input_loop:
  $P0 = prompt(level)
  if null $P0 goto done
  $S0 = $P0
  $S0 .= "\n" # add back in the newline the prompt chomped
  input_line .= $S0

execute_line:
  push_eh loop_error
    $P2 = compileTcl(input_line)
    retval = $P2()
  pop_eh
  # print out the result of the evaluation.
  if_null retval, input_loop_continue
  if retval == '' goto input_loop_continue
  say retval
  goto input_loop_continue

loop_error:
  .catch()
 
  .get_severity($I0)
  if $I0 != .EXCEPT_EXIT goto loop_ok
  .rethrow()

loop_ok:
  .local string exception_msg
  .get_message(exception_msg)
  # Are we just missing a close-foo?
  if exception_msg == 'missing close-brace'   goto input_loop_continue2
  if exception_msg == 'missing close-bracket' goto input_loop_continue2
  if exception_msg == 'missing "'             goto input_loop_continue2

loop_error_real:
  .get_stacktrace($S0)
  print $S0

input_loop_continue:
  level = 1
  input_line = ''
  goto input_loop

input_loop_continue2:
  level = 2
  goto input_loop

open_file:
  tcl_interactive = 0

file:
  filename = shift argv
  $P0 = new 'TclString'
  $P0 = filename
  set_root_global ['_tcl'], '$script', $P0
  .local string contents
  $P99 = open filename, 'r'
  contents = $P99.'readall'()

  .set_tcl_argv()

run_file:
  push_eh file_error
    load_init_tcl()
    $P2 = compileTcl(contents, 'bsnl' => 1)
    $P2()
  pop_eh
  goto done

badfile:
  $S0 = "couldn't read file \""
  $S0 = $S0 . filename
  $S0 = $S0 . '": no such file or directory'
  die $S0

oneliner:
  .set_tcl_argv()

  load_init_tcl()

  .local string tcl_code
  tcl_code = opt['e']
  $P3 = compileTcl(tcl_code)
  push_eh file_error
    $P3()
  pop_eh

done:
  exit 0

file_error:
  .catch()
  .get_severity($I0)

  if $I0 == .EXCEPT_EXIT goto exit_exception
  .get_return_code($I0)
  if $I0 == .CONTROL_CONTINUE goto continue_outside_loop
  if $I0 == .CONTROL_BREAK    goto break_outside_loop
  .get_stacktrace($S0)
  print $S0
  exit 0 # XXX wrong exit value

continue_outside_loop:
  say 'invoked "continue" outside of a loop'
  exit 0 # XXX should be a tcl_error

break_outside_loop:
  say 'invoked "break" outside of a loop'
  exit 0 # XXX should be a tcl_error

exit_exception:
  .rethrow()
.end

.sub prompt
  .param int level

  .local pmc STDOUT
  STDOUT = getstdout
  .local pmc STDIN
  STDIN = getstdin

  .local string default_prompt
  default_prompt = ''
  if level == 2 goto got_prompt
  default_prompt = '% '

got_prompt:

  .local string varname
  varname = '$tcl_prompt'
  $S0 = level
  varname .= $S0

  .local pmc compileTcl
  compileTcl = get_root_global ['_tcl'], 'compileTcl'

  # XXX Should trap the printed output here, and then display
  # it using the readilne prompt, like everything else.
  # XXX Should be testing this
  push_eh no_prompt
    $P0 = get_global varname
    $P2 = compileTcl($P0)
    $P2()
  pop_eh

  STDOUT.'flush'() 
  # tailcall fails here.
  push_eh eof
    $S0 = STDIN.'readline'()
  pop_eh
  .return($S0)

no_prompt:
  .catch()
  STDOUT.'flush'()
  # tailcall fails here.
  push_eh eof
    $S0 = STDIN.'readline_interactive'(default_prompt)
  pop_eh
  .return ($S0)

eof:
  .catch()
  null $P0
  .return($P0)
.end

# load and run init.tcl

.sub load_init_tcl

    $P0 = get_root_global ['_tcl'], '$quick'
    .Unless($P0, {

        .include 'iglobals.pasm'
        .local pmc tcl_library, config, interp
        tcl_library = get_global '$tcl_library'
        interp = getinterp
        config = interp[.IGLOBALS_CONFIG_HASH]
        .local string slash
        slash = config['slash']

        $S0 = tcl_library
        $S0 .= slash
        $S0 .= 'init.tcl'

        .local pmc script
        $P99 = open $S0, 'r'
        $S0 = $P99.'readall'()

        script = get_root_global ['_tcl'], 'compileTcl'

        # compile to PIR and put the sub(s) in place...
        $P1 = script($S0, 'bsnl'=>1)
        $P1()
    })
.end


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
