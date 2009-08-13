.HLL '_tcl'
.namespace []

=head2 _Tcl::toNumber

Given a PMC, get a number from it.

=cut

.sub toNumber :multi(TclInt)
  .param pmc n
  .prof('_tcl;toNumber :multi(TclInt)')
  .return(n)
.end

.sub toNumber :multi(TclFloat)
  .param pmc n
  .prof('_tcl;toNumber :multi(TclFloat)')
  .return(n)
.end

.sub toNumber :multi(_)
  .param pmc number

  .prof('_tcl;toNumber:multi(_)')
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

=head2 _Tcl::toInteger

Given a PMC, get an integer from it.

=cut

.sub toInteger :multi(TclInt)
  .param pmc n
  .prof('_tcl;toInteger :multi(TclInt)')
  .return(n)
.end

.sub toInteger :multi(_)
  .param pmc value
  .param pmc rawhex :named ('rawhex') :optional
  .param int has_rawhex               :opt_flag

  .prof('_tcl;toInteger :multi(_)')
  unless has_rawhex goto normal
  $S0 = value
  $S0 =  '0x' . $S0
  value = $S0

normal:
  .local pmc integer

  push_eh not_integer_eh
    integer = toNumber(value)
  pop_eh
  $S0 = typeof integer
  if $S0 != 'TclInt' goto not_integer

  copy value, integer

  .return(value)

not_integer:
  $S1 = value
  $S0 = 'expected integer but got "'
  $S0 .= $S1
  $S0 .= '"'
  die $S0

not_integer_eh:
  .catch()
  $S99 = exception
  $I0 = index $S99, 'expected integer'
  if $I0 == -1 goto not_integer # got some other exception, rewrap it.
  .rethrow()
.end

=head2 _Tcl::getIndex

Given a tcl string index and an List pmc, return the corresponding numeric
index.

=cut

.sub getIndex
  .param string idx
  .param pmc    list

  .prof('_tcl;getIndex')
  if idx == 'end' goto end

  $S0 = substr idx, 0, 4
  if $S0 == 'end-' goto before_end
  if $S0 == 'end+' goto after_end

  push_eh bad_index
    $I0 = toInteger(idx)
  pop_eh
  .return($I0)

before_end:
  $S0 = substr idx, 4
  push_eh bad_index
    $I0 = toInteger($S0)
  pop_eh

  $I1 = elements list
  dec $I1
  $I0 = $I1 - $I0
  .return($I0)

after_end:
  $S0 = substr idx, 4
  push_eh bad_index
    $I0 = toInteger($S0)
  pop_eh

  $I1 = elements list
  dec $I1
  $I0 = $I1 + $I0
  .return($I0)

end:
  $I0 = elements list
  dec $I0
  .return($I0)

bad_index:
  .catch()
  $S99 = exception
  $S0 = 'bad index "'
  $S0 .= idx
  $S0 .= '": must be integer?[+-]integer? or end?[+-]integer?'
  $S1 = ' (looks like invalid octal number)'
  $I0 = index $S99, $S1
  if $I0 == -1 goto bad_index_done
  $I0 = index idx, '--'
  if $I0 != -1 goto bad_index_done # don't squawk on negative indices..
  $S0 .= $S1
bad_index_done:
  die $S0
.end

=head2 _Tcl::getChannel

Given a string, return the appropriate channel.

=cut

.sub getChannel
  .param string channelID

  .prof('_tcl;getChannel')
  .local pmc channels
  channels = get_global 'channels'

  .local pmc io_obj
  io_obj = channels[channelID]
  if null io_obj goto bad_channel

  $S0 = typeof io_obj
  if $S0 == 'FileHandle' goto done
  if $S0 == 'TCPStream' goto done

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

  .prof('_tcl;splitNamespace')
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

=head2 _Tcl::getCallLevel

Given a pmc containing the tcl-style call level, return an int-like pmc
indicating the parrot-style level, and an integer with a boolean 0/1 -
was this a valid tcl-style level, or did we get this value as a default?

=cut

.sub getCallLevel
  .param pmc tcl_level

  .prof('_tcl;getCallLevel')
  .local pmc parrot_level, defaulted, orig_level
  defaulted = new 'TclInt'
  defaulted = 0

  .local pmc call_chain
  .local int call_level
  call_chain = get_root_global ['_tcl'], 'call_chain'
  call_level = elements call_chain
  orig_level = new 'TclInt'
  orig_level = call_level

  .local int num_length

get_absolute:
  # Is this an absolute?
  $S0 = tcl_level
  $S1 = substr $S0, 0, 1, ''
  if $S1 != '#' goto get_integer
  push_eh default
    parrot_level = toNumber($S0)
  pop_eh
  goto bounds_check

get_integer:
  push_eh default
    parrot_level = toNumber(tcl_level)
  pop_eh

  if parrot_level < 0 goto default_no_eh
  parrot_level = orig_level - parrot_level
  goto bounds_check

default:
  .catch()
default_no_eh:
  defaulted = 1
  parrot_level = new 'TclInt'
  parrot_level = orig_level - 1
  # fallthrough.

bounds_check:
  # Are we < 0 ?
  if parrot_level < 0          goto bad_level
  if parrot_level > orig_level goto bad_level

  $I1 = defaulted
  .return(parrot_level,$I1)

bad_level:
  $S0 = tcl_level
  $S0 = 'bad level "' . $S0
  $S0 = $S0 . '"'
  die $S0
.end

=head2 _Tcl::backslash_newline_subst

Given a string of tcl code, perform the backslash/newline subsitution.

=cut

.sub 'backslash_newline_subst'
  .param string contents

  .prof('_tcl;backslash_newline_subst')
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
  substr contents, $I0, $I1, ' '
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
