.HLL 'tcl'
.namespace []

.sub '&break'
    .param pmc argv :slurpy

    .prof('tcl;&break')
    
    .int(argc, elements argv)

    .If (argc !=0, {
        die 'wrong # args: should be "break"'
    })
 
    tcl_break
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
