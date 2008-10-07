
=head1 TITLE

parse.pir - Parsing support subroutines for [expr]

=cut

.sub 'invalid_octal'
    .param pmc mob
    .param pmc adverbs :named :slurpy

    $S0 = mob
    $S0 = '0' . $S0
    $S0 = 'expected integer but got "' . $S0
    $S0 = $S0 . '" (looks like invalid octal number)'

    die $S0
.end

.sub 'unknown_math_function'
    .param pmc mob
    .param pmc adverbs :named :slurpy

    $S0 = mob[0]
    $S0 = 'unknown math function "' . $S0
    $S0 = $S0 . '"'

    die $S0
.end

.sub 'error'
    .param pmc    mob
    .param string msg
    .param pmc    adverbs :named :slurpy

    die msg
.end

.sub 'syntax_error'
    .param pmc    mob
    .param string msg
    .param pmc    adverbs :named :slurpy

    .local pmc target
    target = getattribute mob, '$.target'

    $S0 = target
    $S0 = 'syntax error in expression "' . $S0
    $S0 .= '": '
    $S0 .= msg

    die $S0
.end

.sub 'syntax_error_variable_or_function'
    .param pmc    mob
    .param pmc    adverbs :named :slurpy

    .local string target
    $P0 = getattribute mob, '$.target'
    target = $P0

    .local string msg
    msg = 'the word "'
    msg .= target
    msg .= '" requires a preceding $ if '
    msg .= "it's a variable or function arguments if it's a function"

    syntax_error(mob, msg, 'adverbs' => adverbs)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
