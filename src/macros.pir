.include 'languages/tcl/src/returncodes.pasm'

=head1 exception handling macros

Exception creation can be fairly verbose. These macros provide an API
of sorts to the exceptions.

=cut

=head2 catch ()

Preamble for any tcl-related exception handler.

=cut

.macro catch ()
  .local pmc exception
  get_results '0', exception
.endm

=head2 rethrow ()

Re-throw the current exception

=cut

.macro rethrow ()
  throw exception
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

=head2 cloneable ()

Simplistic implementation of C<clone> vtable

=cut

.macro cloneable ()

.sub clone :vtable
  .local pmc obj
  obj = new 'Undef'
  assign obj, self
  .return(obj)
.end

.endm

=head2 dumper

Utility macro to simplify generating output during debug cycles.

=cut

.macro dumper(dingus)
  load_bytecode 'library/dumper.pbc'
  load_bytecode 'PGE/Dumper.pbc'
  _dumper(.dingus)
.endm

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
