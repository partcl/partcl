.HLL 'tcl'
.namespace []

.sub 'glob_options' :anon :immediate
    .local pmc opts
    opts = split ' ', 'directory:s join nocomplain path:s tails types:s'

    .return(opts)
.end

.sub '&glob'
    .param pmc argv :slurpy

    .const 'Sub' options = 'glob_options'
    .const 'Sub' select_switches = 'select_switches'

    .local pmc globber
    globber = compreg 'Tcl::Glob'

    .local pmc switches
    switches = select_switches(options, argv, 1, 1)
    .argc()

    .If(argc==0, {
        tcl_error 'wrong # args: should be "glob ?switches? name ?name ...?"'
    })

    .local string directory
    directory = '.'

    .local pmc os
    os = new 'OS'

    .local pmc entries_core
    entries_core = os.'readdir'(directory)
    .list(entries) # core parrot PMC here isn't featureful enough
    assign entries, entries_core

    .list(patterns)
    .iter(argv)
    .While(iterator, {
        .local string pattern
        pattern = shift iterator
        .local pmc rule
        rule = globber.'compile'(pattern)
        push patterns, rule
    })

    .list(results)
    .iter(entries)
    .While(iterator, {
        .local pmc entry
        entry = shift iterator
        .local pmc pattern_iter
        pattern_iter = iter patterns
        .While(pattern_iter, {
            .local pmc match
            match = shift pattern_iter
            match = match(entry)
            .If(match, {
                push results, entry
                goto end_inner
            })
        })
        end_inner:
    })

    .return(results)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
