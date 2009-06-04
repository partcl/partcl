.include 'src/returncodes.pasm'

=head1 math macros

=head2 if_nan(reg,target)

If the specified register contains a NaN, goto the specified label.

=cut

.macro if_nan(reg,target)
  # XXX this should use .macro_local
  $N9999 = .reg
  $S9999 = $N9999
  if $S9999 == 'NaN' goto .target
.endm

=head2 domain_error()

Generate an arithmetic domain error

=cut

.macro domain_error()
domain_error:
  $P9999 = root_new ['parrot'; 'TclList']
  $P9999[0] = 'ARITH'
  $P9999[1] = 'DOMAIN'
  $S9999 = 'domain error: argument not in valid range'
  $P9999[2] = $S9999
  tcl_error $S9999, $P9999
.endm

=head1 exception handling macros

Exception creation can be fairly verbose. These macros provide an API
of sorts to the exceptions.

=head2 catch ()

Preamble for any tcl-related exception handler.

=cut

.macro catch ()
  .local pmc exception
  get_results '0', exception
  pop_eh
.endm

=head2 rethrow ()

Re-throw the current exception

=cut

.macro rethrow ()
  rethrow exception
.endm

=head2 get_stacktrace (OUT string message)

RT#40687: return the stacktrace for the current exception

=cut

.macro get_stacktrace (output)
  .output = exception['message']
  .output .= "\n"
.endm

=head2 get_message (OUT string message)

Get the simple string message for the current exception.

=cut

.macro get_message (output)
  .output = exception["message"]
.endm

=head2 get_severity (OUT int level)

Get the severity level of the current exception.

=cut

.macro get_severity (output)
  .output = exception["severity"]
.endm

=head2 get_return_code

Get the tcl-level code for this exception. (TCL_CATCH, TCL_RETURN), etc.
Note that TCL_OK is not one of the options here: that's implied by a
normal parrot C<.return>

=cut

.macro get_return_code (output)
   .output = -1
   push_eh .$bad_handler
    .output = exception["type"]
   pop_eh

.label $bad_handler:
.endm

=head1 Utility methods

the implementation of these never change:
define them once and just include them.

=head2 dumper

Utility macro to simplify generating output during debug cycles.

=cut

.macro dumper(dingus)
  load_bytecode 'dumper.pbc'
  load_bytecode 'PGE/Dumper.pbc'
  $P9999 = get_root_global ['parrot'], '_dumper'
  $P9999(.dingus)
.endm

=head2 prof

A braindead profiler assistant - swap out the definition here to
enable some very verbose timing information that is
disabled by default.

For now, only items in F<runtime/> use this macro

.macro prof(where)
  $N99999 = time
  printerr '### '
  printerr .where
  printerr ' #'
  printerr $N99999
  printerr "\n"
.endm

=cut

.macro prof(where)
.endm

=head2 parrot_debug

Add this macro to PIR code to dump some verbose parrot
interpreter information.

=cut

.macro parrot_debug(location)

  printerr "@ "
  printerr .location
  printerr "\n"

  .include 'runtime/parrot/include/interpinfo.pasm'

  $I1234 = interpinfo .INTERPINFO_TOTAL_MEM_ALLOC
  printerr "    TOTAL_MEM_ALLOC............: "
  printerr $I1234
  printerr "\n"

  $I1234 = interpinfo .INTERPINFO_DOD_RUNS
  printerr "    DOD_RUNS...................: "
  printerr $I1234
  printerr "\n"

  $I1234 = interpinfo .INTERPINFO_COLLECT_RUNS
  printerr "    COLLECT_RUNS...............: "
  printerr $I1234
  printerr "\n"

  $I1234 = interpinfo .INTERPINFO_ACTIVE_PMCS
  printerr "    ACTIVE_PMCS................: "
  printerr $I1234
  printerr "\n"

  $I1234 = interpinfo .INTERPINFO_ACTIVE_BUFFERS
  printerr "    ACTIVE_BUFFERS.............: "
  printerr $I1234
  printerr "\n"

  $I1234 = interpinfo .INTERPINFO_TOTAL_PMCS
  printerr "    TOTAL_PMCS.................: "
  printerr $I1234
  printerr "\n"

  $I1234 = interpinfo .INTERPINFO_TOTAL_BUFFERS
  printerr "    TOTAL_BUFFERS..............: "
  printerr $I1234
  printerr "\n"

  $I1234 = interpinfo .INTERPINFO_HEADER_ALLOCS_SINCE_COLLECT
  printerr "    HEADER_ALLOCS_SINCE_COLLECT: "
  printerr $I1234
  printerr "\n"

  $I1234 = interpinfo .INTERPINFO_MEM_ALLOCS_SINCE_COLLECT
  printerr "    MEM_ALLOCS_SINCE_COLLECT...: "
  printerr $I1234
  printerr "\n"

  $I1234 = interpinfo .INTERPINFO_TOTAL_COPIED
  printerr "    TOTAL_COPIED...............: "
  printerr $I1234
  printerr "\n"

  $I1234 = interpinfo .INTERPINFO_IMPATIENT_PMCS
  printerr "    IMPATIENT_PMCS.............: "
  printerr $I1234
  printerr "\n"

  $I1234 = interpinfo .INTERPINFO_LAZY_DOD_RUNS
  printerr "    LAZY_DOD_RUNS..............: "
  printerr $I1234
  printerr "\n"

  $I1234 = interpinfo .INTERPINFO_EXTENDED_PMCS
  printerr "    EXTENDED_PMCS..............: "
  printerr $I1234
  printerr "\n"

=for skipping these.

.macro_const INTERPINFO_CURRENT_RUNCORE 14
.macro_const INTERPINFO_CURRENT_SUB     15
.macro_const INTERPINFO_CURRENT_CONT    16
.macro_const INTERPINFO_CURRENT_OBJECT  17
.macro_const INTERPINFO_CURRENT_LEXPAD  18
.macro_const INTERPINFO_EXECUTABLE_FULLNAME     19
.macro_const INTERPINFO_EXECUTABLE_BASENAME     20
.macro_const INTERPINFO_RUNTIME_PREFIX  21

=cut

.endm

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
