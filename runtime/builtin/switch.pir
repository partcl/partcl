.HLL 'Tcl', ''
.namespace []

.sub '&switch'
  .param pmc argv :slurpy
  .local int argc
  argc = elements argv

  .local pmc retval
  .local string mode
  .local int nocase
  nocase = 0
  mode = '-exact'

  if argc < 2 goto bad_args
flag_loop:
  unless argc goto bad_args
  $S0 = shift argv
  $S1 = substr $S0, 0, 1
  if $S0 == '--' goto get_subj
  if $S1 != '-' goto skip_subj

  # ouch!
  if $S0 == '-exact' goto set_mode
  if $S0 == '-glob' goto set_mode
  if $S0 == '-regexp' goto set_mode
  if $S0 == '-nocase' goto set_case
  if $S0 == '-matchvar' goto set_fvar
  if $S0 == '-indexvar' goto set_fvar
  branch bad_flag

set_case:
  nocase = 1
  branch flag_loop

set_mode:
  mode = $S0
  branch flag_loop

set_fvar:
  $S0 = shift argv
  branch flag_loop

get_subj:
  unless argv goto bad_args
  $S0 = shift argv
skip_subj:
  .local string subject
  subject = $S0
  unless nocase goto get_body
  subject = downcase subject

get_body:
  .local pmc body
  argc = elements argv
  if argc != 1 goto body_from_argv

body_from_list:
  .local pmc toList
  toList = get_root_global ['_tcl'], 'toList'

  $P0 = shift argv
  body = toList($P0)
  goto got_body

body_from_argv:
  body = argv

got_body:
  $I0 = elements body
  if $I0 == 0 goto bad_args_with_curlies
  $I0 = $I0 % 2
  if $I0 == 1 goto extra_pattern

  # check to make sure the last option isn't a fall-through
  $S0 = body[-1]
  unless $S0 == '-' goto check_mode
  $S0 = body[-2]
  $S0 = 'no body specified for pattern "' . $S0
  $S0 = $S0 . '"'
  die $S0

check_mode:
  .local string pattern, code
  if mode == '-exact' goto exact_mode
  if mode == '-glob' goto glob_mode
  if mode == '-regexp' goto regex_mode

exact_mode:
exact_loop:
  unless body goto body_end
  pattern = shift body
  code = shift body
  unless nocase goto exact_do
  pattern = downcase pattern
  code    = downcase code

exact_do:
  if subject == pattern goto body_match
  branch exact_loop

glob_mode:
  .local pmc globber, rule
  globber = compreg 'Tcl::Glob'
glob_loop:
  unless body goto body_end
  pattern = shift body
  code = shift body
  unless nocase goto glob_do
  pattern = downcase pattern
  code    = downcase code

 glob_do:
  (rule, $P1, $P2) = globber.'compile'(pattern)
  $P0 = rule(subject)
  if $P0 goto body_match
  branch glob_loop

regex_mode:
  .local pmc tclARE,rule,match
  tclARE = compreg 'PGE::P5Regex'
regex_loop:
  unless body goto body_end
  pattern = shift body
  code = shift body
  unless nocase goto re_do
  pattern = downcase pattern
  code    = downcase code
 re_do:
  rule  = tclARE(pattern)
  match = rule(subject)
  if match goto body_match
  branch glob_loop

body_end:
  if pattern == 'default' goto body_match

  .return ('')

fallthrough:
  $S0  = shift body
  code = shift body
body_match:
  if code == '-' goto fallthrough
  .local pmc compileTcl
  compileTcl = get_root_global ['_tcl'], 'compileTcl'
  $P1 = compileTcl(code)
  .return $P1()

extra_pattern:
  die 'extra switch pattern with no body'

bad_args:
  die 'wrong # args: should be "switch ?switches? string pattern body ... ?default body?"'

bad_args_with_curlies:
  die 'wrong # args: should be "switch ?switches? string {pattern body ... ?default body?}"'

bad_flag:
  $S1 = 'bad option "'
  $S1 .= $S0
  $S1 .= '": must be -exact, -glob, -indexvar, -matchvar, -nocase, -regexp, or --'
  die $S1
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
