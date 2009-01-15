.HLL 'Tcl'
.namespace []

#
# When these subs are invoked, it will load in the actual definition
# of the sub and replace this stub. This allows us to defer the cost of
# loading it for every partcl invocation.
#

#
# XXX Perhaps replace most of the guts here with a call to auto_load?
#

.macro faux_load(subname,filename)
  .include 'iglobals.pasm'
  .local pmc tcl_library, config, interp
  tcl_library = get_global '$tcl_library'
  interp = getinterp
  config = interp[.IGLOBALS_CONFIG_HASH]
  .local string slash
  slash = config['slash']

  $S0 = tcl_library
  $S0 .= slash
  $S0 .= .filename

  .local pmc script
  $P99 = open $S0, 'r'
  $S0 = $P99.'readall'()

  script = get_root_global ['_tcl'], 'compileTcl'

  # compile to PIR and put the sub in place...
  $P1 = script($S0)
  $P1()

  # Now call the version that we just created.
  $P3 = find_name .subname
  .tailcall $P3( args :flat )
.endm

.sub '&parray'
  .param pmc args :slurpy
  .faux_load('&parray','parray.tcl')
.end

.sub '&tcl_wordBreakAfter'
  .param pmc args :slurpy
  .faux_load('&tcl_wordBreakAfter','word.tcl')
.end

.sub '&tcl_wordBreakBefore'
  .param pmc args :slurpy
  .faux_load('&tcl_wordBreakBefore','word.tcl')
.end

.sub '&tcl_endOfWord'
  .param pmc args :slurpy
  .faux_load('&tcl_endOfWord','word.tcl')
.end

.sub '&tcl_startOfNextWord'
  .param pmc args :slurpy
  .faux_load('&tcl_startOfNextWord','word.tcl')
.end

.sub '&tcl_startOfPreviousWord'
  .param pmc args :slurpy
  .faux_load('&tcl_startOfPreviousWord','word.tcl')
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
