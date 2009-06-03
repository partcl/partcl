.HLL 'Tcl'
.namespace []

.sub '&expr'
  .param pmc argv :slurpy

  .local int argc

  .local pmc compileExpr
  compileExpr = get_root_global ['_tcl'], 'compileExpr'

  argc = elements argv
  unless argc goto no_args

  .local string expr
  expr = join ' ', argv

  .local pmc ns, interp
  interp = getinterp
  ns  = interp['namespace'; 1]

  .local pmc runnableExpr
  runnableExpr = compileExpr(expr, 'ns'=>ns)
  .tailcall runnableExpr()

no_args:
  die 'wrong # args: should be "expr arg ?arg ...?"'
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
