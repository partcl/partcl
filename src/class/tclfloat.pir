=head1 TclFloat

Contains overrides for our TclFloat type

=cut

=head2 get_string

Convert to a string for printing.

=cut

.HLL 'parrot'
.namespace ['TclFloat']

.sub 'get_string' :vtable
    .pmc(precision, {get_root_global ['tcl'], '$tcl_precision'})
    
    .If(precision==0, precision=16) # hack to approximate right output.

    .str(fmt, "%.*vg")

    $P1 = new 'ResizablePMCArray'
    $P1 = 2
    $P1[0] = precision 
    $P1[1] = self

    .local string buff
    buff = sprintf fmt, $P1

    # this sprintf variant will return something that looks like
    # an int if it can : if we have no decimal point then tack on
    # on and return

    $I0 = index buff, '.'
    .If($I0==-1, {
        $I1 = index buff, 'e'
        .If($I1==-1, {
	    .If(buff != 'NaN', {
	        buff .= ".0"
		.return(buff)
	    })
         })
    })

    # but if it already had a .0, we might need to remove trailing 0s
    .int(count, 0)
    .int(buflen, {length buff})
loop:
    if count >= buflen goto done
   
    $I1 = ord buff, $I0
    .If($I1 == 48, { # "0"
        inc count
	goto loop
    })
done:
    .If(count, {
        # remove any trailing zeros.
        count *= -1
        chopn buff, count
    })
    .return(buff)
.end
