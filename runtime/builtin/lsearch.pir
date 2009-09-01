.HLL 'tcl'
.namespace []

.sub 'lsearch_options' :anon :immediate
    .local pmc opts
    opts = split ' ', 'all ascii decreasing dictionary exact glob increasing index inline integer nocase not real regexp sorted start subindices'

    .return(opts)
.end

.sub '&lsearch'
  .param pmc argv :slurpy

  .const 'Sub' options = 'lsearch_options'

  .local pmc select_switches, switches
  select_switches  = get_root_global ['_tcl'], 'select_switches'
  switches = select_switches(options, argv, 0, 1, 'option')

  .argc()
  if argc != 2 goto bad_args

  .local string option, pattern
  .local pmc list

  list = shift argv
  list = list.'getListValue'()
  pattern = shift argv

  .iter(list)

  .local int pos, result
  result = -1
  pos = 0

  .local int lc
  lc = exists switches['nocase']
  unless lc goto got_case
  pattern = downcase pattern

got_case:
  $I1 = exists switches['exact']
  if $I1 goto exact_loop
  $I1 = exists switches['regexp']
  if $I1 goto regexp_begin

glob_begin:
  .local pmc globber
  globber = compreg 'Tcl::Glob'
  .local pmc rule, match
  rule = globber.'compile'(pattern)

glob_loop:
  unless iterator goto done
  $S0 = shift iterator
  unless lc goto glob_match
  $S0 = downcase $S0
glob_match:
  match = rule($S0)
  unless match goto glob_next
  result = pos
  goto done
glob_next:
  inc pos
  goto glob_loop

regexp_begin: # very similar to glob_...
  .local pmc regexp
  regexp = compreg 'PGE::P5Regex'
  .local pmc rule, match
  rule = regexp(pattern)

regexp_loop:
  unless iterator goto done
  $S0 = shift iterator
  unless lc goto regexp_match
  $S0 = downcase $S0
regexp_match:
  match = rule($S0)
  unless match goto regexp_next
  result = pos
  goto done
regexp_next:
  inc pos
  goto regexp_loop

exact_loop:
  unless iterator goto done
  $S0 = shift iterator
  unless lc goto exact_match
  $S0 = downcase $S0
exact_match:
  if $S0 != pattern goto exact_next
  result = pos
  goto done
exact_next:
  inc pos
  goto exact_loop

done:
  .return (result)

bad_args:
  die 'wrong # args: should be "lsearch ?options? list pattern"'
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
