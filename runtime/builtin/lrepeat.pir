.HLL 'tcl'
.namespace []

.sub '&lrepeat'
    .param pmc argv :slurpy
    .argc()

    .If(argc < 2, {
        die 'wrong # args: should be "lrepeat positiveCount value ?value ...?"'
    })

    .local int count
    count = shift argv

    .If(count < 1, {
        die 'must have a count of at least 1'
    })

    .list(retval)

    .int(pos, 1)
    .While(pos <= count, {
        .iter(argv)
	.While(iterator, {
	    $P0 = shift iterator
            push retval, $P0
	})
        inc pos
    })

  .return(retval)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
