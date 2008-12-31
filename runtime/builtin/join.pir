.HLL 'Tcl'
.namespace []

.sub 'join'
  .param pmc argv :slurpy

  .local int argc
  argc = elements argv
  if argc < 1 goto bad_args
  if argc > 2 goto bad_args
  # get necessary conversion subs
  .local pmc toList
  toList = get_root_global ['_tcl'], 'toList'
  .local pmc a_list
  a_list = argv[0]
  a_list = toList(a_list)
  .local string a_joinString
  if argc < 2 goto default_joinString
  a_joinString = argv[1]
  goto done_joinString
default_joinString:
  a_joinString = ' '
done_joinString:
  .local pmc R
  .local pmc temp

$S0 = join a_joinString, a_list
.return ($S0)
bad_args:
  die 'wrong # args: should be "join list ?joinString?"'
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
