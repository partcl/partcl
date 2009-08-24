=head1 TclList

A Tcl-style list

=cut

.HLL 'parrot'
.namespace [ 'TclList' ]

.sub class_init :anon :load
  .local pmc core, tcl
  core = get_class 'ResizablePMCArray'
  tcl = subclass core, 'TclList'
.end

.HLL 'tcl'
.namespace []

.sub 'mapping' :anon :load
  .local pmc core
  core = get_class 'ResizablePMCArray'
  .local pmc tcl
  tcl  = get_class 'TclList'
  .local pmc interp
  interp = getinterp
  interp.'hll_map'(core,tcl)
  core = get_class 'Array'
  interp.'hll_map'(core,tcl)
.end

.HLL '_tcl'
.namespace []

.sub 'mapping' :anon :load
  .local pmc core
  core = get_class 'ResizablePMCArray'
  .local pmc tcl
  tcl  = get_class 'TclList'
  .local pmc interp
  interp = getinterp
  interp.'hll_map'(core,tcl)
  core = get_class 'Array'
  interp.'hll_map'(core,tcl)
.end

.HLL 'parrot'
.namespace [ 'TclList' ]

=head2 getListValue

Return a list-ified version of this Tcl PMC.

=cut

.sub getListValue :method
  .return(self)
.end

=head2 reverse

Reverse ourselves.

This algorithm is very generic and could easily be
moved back into parrot core where we'd be happy to inherit it.

=cut

.sub reverse :method
    .local int low,high
    low = 0
    high = elements self

    .local pmc swap1, swap2
  loop:
    if low >= high goto done
    dec high
    swap1 = self[low]
    swap2 = self[high]
    self[low] = swap2
    self[high] = swap1
    inc low
    goto loop
  done: 
    .return(self)
.end

=head2 get_string

Returns the list as a string

=cut

.sub get_string :vtable
    .local pmc retval
    retval = new 'ResizablePMCArray'

    .local int elems
    elems = self

    .local pmc iterator
    iterator = iter self

    .local string elem_s
    .local int elem_len
    .local string new_s

    .local int first_elem
    first_elem = 1
  loop:
    unless iterator goto done
    elem_s = shift iterator
    elem_len = length elem_s

    if elem_len != 0 goto has_length
    new_s = '{}'
    goto append_elem

  has_length:
    .local int count, pos, brace_check_pos, has_braces
    count = 0
    pos = 0
    brace_check_pos = 0
    has_braces = 0

    .local int char
  elem_loop:
    if pos >= elem_len goto elem_loop_done
    char = ord elem_s, pos
    if char == 0x7b goto open_count
    if char == 0x7d goto close_count
    goto elem_loop_next
  open_count:  
    inc count
    has_braces = 1
    goto elem_loop_next
  close_count:
    dec count
    if count < 0 goto escape
    brace_check_pos = pos
  elem_loop_next:
    inc pos
    goto elem_loop
  elem_loop_done:

    if count goto escape
    unless has_braces goto done_brace_check
    if count goto done_brace_check
    $I0 = elem_len - 1
    if brace_check_pos == $I0 goto done_brace_check

    # escape {ab}\, but brace-wrap anything else. 
    $I0 = elem_len - 2
    if brace_check_pos != $I0 goto quote
    $I0 = elem_len - 1
    char = ord elem_s, $I0
    if char != 0x5c goto quote

    goto escape

  done_brace_check:
    # trailing slash
    $I0 = elem_len - 1
    $I1 = index elem_s, "\\", $I0
    if $I0 == $I1 goto escape

    $I0 = index elem_s, "\""
    if $I0 != -1 goto quote

    $I0 = index elem_s, '['
    if $I0 != -1 goto quote

    # only check hashes on first elem.
    unless first_elem goto done_hash
    $I0 = index elem_s, '#'
    if $I0 != -1 goto quote

  done_hash:
    $I0 = index elem_s, '$'
    if $I0 != -1 goto quote

    $I0 = index elem_s, ';'
    if $I0 != -1 goto quote

    # \'d constructs 
    $I0 = index elem_s, ']'
    if $I0 != -1 goto escape

    $I0 = index elem_s, "\\"
    if $I0 != -1 goto escape

    # {}'d constructs 
    $I0 = find_cclass .CCLASS_WHITESPACE, elem_s, 0, elem_len
    if elem_len != $I0 goto quote

    new_s = elem_s 
  goto append_elem

  escape:
    .local pmc string_t
    string_t = new 'String'
    string_t = elem_s
    string_t.'replace'("\\", "\\\\")
    string_t.'replace'("\t", "\\t")
    string_t.'replace'("\f", "\\f")
    string_t.'replace'("\n", "\\n")
    string_t.'replace'("\r", "\\r")
    string_t.'replace'("\v", "\\v")
    string_t.'replace'("\;", "\\;" )
    string_t.'replace'("$",  "\\$" )
    string_t.'replace'("}",  "\\}" )
    string_t.'replace'("{",  "\\{" )
    string_t.'replace'(" ",  "\\ " )
    string_t.'replace'("[",  "\\[" )
    string_t.'replace'("]",  "\\]" )
    string_t.'replace'("\"", "\\\"")
    new_s = string_t
    goto append_elem

  quote:
    new_s = '{' . elem_s
    new_s = new_s . '}'

  append_elem:
    push retval, new_s
    first_elem = 0
    goto loop

  done:
    .local string retval_s
    retval_s = join " ", retval
    .return(retval_s)
.end

=head2 assign_pmc

Copy the contents of other to self.

=cut

.sub assign_pmc :vtable
    .param pmc other

    $I0 = does other, 'array'
    if $I0 goto array_style

    $I0 = isa other, 'String'
    if $I0 goto string_style

    $I0 = isa other, 'Undef'
    if $I0 goto undef_style

    die "unable to assign to TclList"

  array_style:
    .local int size
    .local pmc iterator, elem
    iterator = iter other
    self = 0
  loop:
    unless iterator goto done
    elem = shift iterator
    size = elements other
    push self, elem
    goto loop
  done:
    .return()

  string_style:
    .local pmc tclstring
    tclstring = new 'TclString'
    $S0 = other
    tclstring = $S0
    .return()

  undef_style:
    self = copy other
    .return()
.end

=head getDictValue

=cut

.sub getDictValue :method

  .local int sizeof_list
  sizeof_list = elements self

  $I0 = mod sizeof_list, 2
  if $I0 == 1 goto odd_args

  .local pmc result
  result = new 'TclDict'

  .local int pos
  pos = 0

loop:
  if pos >= sizeof_list goto done
  $S1 = self[pos]
  inc pos
  $P2 = self[pos]
  inc pos
  $I0 = isa $P2, 'String'
  if $I0 goto is_string
is_list:
  $P2 = $P2.'getDictValue'()
  result[$S1] = $P2
  goto loop

is_string:
  # Can we listify the value here? If so, make it into a dictionary.
  $P3 = $P2.'getListValue'()
  $I0 = elements $P3
  if $I0 <= 1 goto only_string
  push_eh only_string
    $P3 = $P3.'getDictValue'()
  pop_eh
  result[$S1] = $P3
  goto loop

only_string:
  result[$S1] = $P2
  goto loop

done:
  .return (result)

odd_args:
  die 'missing value to go with key'
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
