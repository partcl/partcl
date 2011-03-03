.HLL '_tcl'
.namespace []

=head2 _Tcl::toNumber

Given a PMC, get a number from it.

=cut

.sub toNumber :multi(TclInt)
  .param pmc n
  .return(n)
.end

.sub toNumber :multi(TclFloat)
  .param pmc n
  .return(n)
.end

.sub toNumber :multi(_)
  .param pmc number

  .local string str
  .local int    len
  str = number
  len = length str
  .include 'cclass.pasm'

  .local pmc parse
  .local pmc match

  parse = get_root_global ['parrot'; 'TclExpr'; 'Grammar'], 'number'
  $I0 = find_not_cclass .CCLASS_WHITESPACE, str, 0, len
  match = parse(str, 'pos'=>$I0, 'grammar'=>'TclExpr::Grammar')

  $I0 = match.'to'()
  $I1 = len - $I0
  $I0 = find_not_cclass .CCLASS_WHITESPACE, str, $I0, $I1
  if $I0 < len goto NaN

  unless match goto NaN

  .local pmc astgrammar, astbuilder, ast
  astgrammar = new ['TclExpr'; 'PAST'; 'Grammar']
  astbuilder = astgrammar.'apply'(match)
  ast = astbuilder.'get'('past')

  .local string className
  .local pmc    value

  className = ast['class']
  value     = ast['value']

  # Create a PMC of the appropriate type based on the string value.
  number = new className
  if className == 'TclInt' goto found_int
  $N0 = value
  number = $N0
  .return (number)

found_int:
  $I0 = value
  number = $I0
  .return (number)

NaN:
  $S1 = 'expected floating-point number but got "'
  $S0 = number
  $S1 .= $S0
  $S1 .= '"'
  die $S1
.end

=head2 _Tcl::getIndex

Given a tcl-style index and a string|list, return the corresponding
parrot-style index.

A lot of this work could probably be pushed into the AST.

=cut

.sub 'getIndex'
    .param string idx
    .param pmc    obj

    .local pmc parser
    parser = get_root_global ['parrot'; 'TclExpr'; 'Grammar'], 'string_index'

    .local pmc match
    match = parser(idx, 'pos'=>0, 'grammar'=>'TclExpr::Grammar')

    unless match goto bad_index
    .int(idx_len, {length idx})
   
    $I0 = match.'to'()

    unless $I0 == idx_len goto bad_index # must match whole thing.

    .int(obj_len, {elements obj})
    dec obj_len
    .If(idx == 'end', {
        .return(obj_len)
    })

    $S0 = substr idx, 0, 4
    .If($S0 == 'end-', {
        $S0 = substr idx, 4
        $I0 = $S0
        $I1 = obj_len - $I0
        .return($I1)
    })
    .If($S0 == 'end+', {
        $S0 = substr idx, 4
        $I0 = $S0
        $I1 = obj_len + $I0
        .return($I1)
    })

    $I0 = index idx, '+'
    .local string str_l, str_r
    .local int    int_l, int_r
    .If($I0 >0 , {
        # get both integers and add them.
        str_l = substr idx, 0, $I0 
        inc $I0
        str_r = substr idx, $I0
	int_l = str_l
	int_r = str_r

        $I0 = int_l + int_r
	.return($I0)
    })

    $I0 = index idx, '-'
    .If($I0 > 0, {
        # get both integers and subtract them.
        str_l = substr idx, 0, $I0 
        inc $I0
        str_r = substr idx, $I0
	int_l = str_l
	int_r = str_r

        $I0 = int_l - int_r
	.return($I0)
    })

    # otherwise, it's just a plain integer.
    $I0 = idx
   .return($I0)

bad_index:
  $S0 = 'bad index "'
  $S0 .= idx
  $S0 .= '": must be integer?[+-]integer? or end?[+-]integer?'
  tcl_error $S0
.end

=head2 _Tcl::getChannel

Given a string, return the appropriate channel.

=cut

.sub getChannel
  .param string channelID

  .local pmc channels
  channels = get_global 'channels'

  .local pmc io_obj
  io_obj = channels[channelID]
  if null io_obj goto bad_channel

  $S0 = typeof io_obj
  if $S0 == 'FileHandle' goto done
  if $S0 == 'Socket' goto done

  # should never happen
  goto bad_channel

done:
  .return (io_obj)

bad_channel:
  $S0 = 'can not find channel named "'
  $S0 .= channelID
  $S0 .= '"'
  die $S0

.end

=head2 _Tcl::splitNamespace

Given a string namespace, return an array of names.

=cut

.sub splitNamespace
  .param string name
  .param int    depth     :optional
  .param int    has_depth :opt_flag

  if has_depth goto depth_set
  depth = 0

depth_set:
  .local pmc colons, split
  colons = get_root_global ['_tcl'], 'colons'
  split  = get_root_global ['parrot'; 'PGE'; 'Util'], 'split'

  .local pmc ns_name
  ns_name = split(colons, name)
  $I0 = elements ns_name
  if $I0 == 0 goto relative
  $S0 = ns_name[0]
  if $S0 != '' goto relative

absolute:
  $P1 = shift ns_name
  goto return

relative:
  .local pmc interp
  interp = getinterp
relative_loop:
  inc depth
  $P0 = interp['sub'; depth]
  $P0 = $P0.'get_namespace'()
  $P0 = $P0.'get_name'()
  $S0 = $P0[0]
  if $S0 == '_tcl' goto relative_loop

  $I0 = elements $P0
combine_loop:
  dec $I0
  if $I0 == 0 goto return
  $P1 = $P0[$I0]
  unshift ns_name, $P1
  goto combine_loop

return:
  .return(ns_name)
.end

=head2 _Tcl::backslash_newline_subst

Given a string of tcl code, perform the backslash/newline subsitution.

=cut

.sub 'backslash_newline_subst'
  .param string contents

  .local int len
  len = length contents

  # perform the backslash-newline substitution
  $I0 = -1
backslash_loop:
  inc $I0
  if $I0 >= len goto done
  $I1 = ord contents, $I0
  if $I1 != 92 goto backslash_loop # \\
  inc $I0
  $I2 = $I0
  $I1 = ord contents, $I2
  if $I1 == 10 goto space # \n
  if $I1 == 13 goto space # \r
  goto backslash_loop
space:
  inc $I2
  if $I0 >= len goto done
  $I1 = is_cclass .CCLASS_WHITESPACE, contents, $I2
  if $I1 == 0 goto not_space
  goto space
not_space:
  dec $I0
  $I1 = $I2 - $I0
  contents = replace contents, $I0, $I1, ' '
  dec $I1
  len -= $I1
  goto backslash_loop

done:
  .return (contents)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
