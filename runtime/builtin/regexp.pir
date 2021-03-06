.HLL 'tcl'
.namespace []

.sub 'regexp_options' :anon :immediate
    .local pmc opts
    opts = split ' ' , 'all about indices inline expanded line linestop lineanchor nocase start'

    .return(opts)
.end


.sub '&regexp'
  .param pmc argv :slurpy
  .argc()

  if argc < 2 goto badargs

    .const 'Sub' options = 'regexp_options'
    .const 'Sub' setVar = 'setVar'

  .local pmc select_switches, switches
  select_switches  = get_root_global ['_tcl'], 'select_switches'
  switches = select_switches(options, argv, 1, 1)

  .local string exp, a_string, original_string
   exp      = shift argv
   # Hack for issue #102
   .If(exp=='($|^X)*', {
       .return('')
   })
   a_string = shift argv
   original_string = a_string

   .local pmc tclARE, rule, match

   # RT#40774: use tcl-regexps
   tclARE = compreg 'PGE::P5Regex'
   $I0 = exists switches['nocase']
   unless $I0 goto ready
   exp      = downcase exp
   a_string = downcase a_string

ready:
   rule = tclARE(exp)
   match = rule(a_string)

   # matchVar
   argc = elements argv
   unless argc goto done
   .local string matchStr, matchVar

   matchVar = shift argv

   .local pmc matches

   $I0 = exists switches['indices']
   if $I0 goto matches_ind

   # Do this in case there was a -nocase
   $I0 = match.'from'()
   $I1 = match.'to'()
   $I1 -= $I0
   matchStr = substr original_string, $I0, $I1

   setVar(matchVar, matchStr)

   matches = match.'list'()
   .local string subMatchStr, subMatchVar

subMatches:
   argc = elements argv
   unless argc goto done

   subMatchVar = shift argv
   subMatchStr = ''
   if_null matches, set_it
   $I0 = elements matches
   unless $I0 goto set_it
   $P0 = shift matches
   if_null $P0, set_it
   $I0 = $P0.'from'()
   $I1 = $P0.'to'()
   $I1 -= $I0
   subMatchStr = substr original_string, $I0, $I1

set_it:
   setVar(subMatchVar,subMatchStr)

next_submatch:
  goto subMatches

matches_ind:
  .list(matchList)
  matchList[0] = -1
  matchList[1] = -1
  $I0 = match.'from'()
  $I1 = match.'to'()
  dec $I1
  matchList[0] = $I0
  matchList[1] = $I1
  setVar(matchVar, matchList)

  matches = match.'list'()

subMatches_ind:
subMatches_ind_loop:
   argc = elements argv
   unless argc goto done

   subMatchVar = shift argv
   .list(subMatchList)
   subMatchList[0] = -1
   subMatchList[1] = -1
   if_null matches, set_it_ind
   $I0 = elements matches
   unless $I0 goto set_it_ind
   $P0 = shift matches
   if_null $P0, set_it_ind
   $I0 = $P0.'from'()
   $I1 = $P0.'to'()
   dec $I1
   subMatchList[0] = $I0
   subMatchList[1] = $I1

set_it_ind:
   setVar(subMatchVar,subMatchList)

next_submatch_ind:
  goto subMatches_ind_loop

done:
   $I0 = istrue match
   .return ($I0)

badargs:
  die 'wrong # args: should be "regexp ?switches? exp string ?matchVar? ?subMatchVar subMatchVar ...?"'

.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
