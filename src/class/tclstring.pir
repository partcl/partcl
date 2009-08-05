=head1 TclString

Contains overrides for our TclString type 

=cut

.HLL 'parrot'
.namespace ['TclString']


=head2 getListValue

Convert to a List.

=cut

.sub getListValue :method
    .prof('parrot;TclString;getListValue')

    .local pmc retval
    retval = root_new ['parrot'; 'TclList']

    .local string str            # our string value
    str = self

    .local int pos               # position in the string
    pos = -1                     # we increment it before we use it

    .local int len               # length of the string
    len = length str

    .local int character         # which character we're testing */
    .local string element_string # string chunk to add to the list */
    .local int element_length    # size of chunk to add to list */
    .local pmc element_pmc       # An item to add to the list */
    .local int peek_pos          # keep track of pos when scanning ahead */
    .local int depth             # keep track of nested {} pairs

    .local string follows_chunk  # text that follows a } or "
    .local int chunk_length      # length of the offending text
    .local int ws_pos            # position of whitespace after follows_chunk

   # Trim any whitespace before a word
eat_space:
    inc pos
    $I0 = is_cclass .CCLASS_WHITESPACE, str, pos # 
    if $I0 goto eat_space

    if pos >= len goto done

    character = ord str, pos 
    if character != 123 goto check_char_quote
    depth = 1
    peek_pos = pos

find_close_bracket:
    inc peek_pos
    if peek_pos < len goto peek_pos_ok
    tcl_error "unmatched open brace in list"

peek_pos_ok:
    character = ord str, peek_pos
    if character != 123 goto   check_char_close_bracket
    inc depth
    goto find_close_bracket

check_char_close_bracket:
    if character != 125 goto check_char_backslash

    dec depth
    if depth goto find_close_bracket

    $I0 = peek_pos + 1
    if $I0 >= len goto found_close_bracket

    $I0 = peek_pos + 1
    $I1 = is_cclass .CCLASS_WHITESPACE, str, $I0
    if $I1 goto found_close_bracket

    inc peek_pos

    $I0 = len - peek_pos
    ws_pos = find_cclass .CCLASS_WHITESPACE, str, peek_pos, $I0
    chunk_length = ws_pos - peek_pos
    follows_chunk = substr str, peek_pos, chunk_length

    $S0 = 'list element in braces followed by "'
    $S0 .= follows_chunk
    $S0 .= '" instead of space'
    tcl_error $S0

found_close_bracket:
    element_length = peek_pos - pos
    inc pos
    dec element_length
    element_string = substr str,pos, element_length

    pos += element_length
    inc pos

    push retval, element_string
    goto eat_space

check_char_backslash:
    if character != 92 goto find_close_bracket
    inc peek_pos
    goto find_close_bracket

    check_char_quote:
    if character != 34 goto peek_next
    # find the closing '"'
    inc pos
    peek_pos = pos
quote_loop:
    if peek_pos < len goto check_peek_backslash
    tcl_error "unmatched open quote in list"

check_peek_backslash:
    character = ord str, peek_pos
    if character != 92 goto check_quote
    peek_pos += 2
    goto quote_loop

check_quote:
    if character == 34 goto found_quote
    inc peek_pos
    goto quote_loop

peek_next:
    peek_pos = pos

word_loop:
    if peek_pos >= len goto extract
    $I0 = ord str, peek_pos
    if $I0 != 92 goto check_word_end
    peek_pos += 2
    goto word_loop

check_word_end:
    $I0 = is_cclass .CCLASS_WHITESPACE, str, peek_pos
    if $I0 goto extract

    inc peek_pos
    goto word_loop

extract:
    element_length = peek_pos - pos
    element_string = substr str, pos, element_length

    element_pmc = root_new ['parrot'; 'TclConst']
    element_pmc = element_string
    push retval, element_pmc

    # find the next pos
    pos = peek_pos
    goto eat_space

found_quote:
    $I0 = peek_pos + 1
    if $I0 >= len goto found_close_quote

    $I0 = peek_pos + 1
    $I1 = is_cclass .CCLASS_WHITESPACE, str, $I0
    if $I1 goto found_close_quote

    inc peek_pos
    $I0 = len-peek_pos
    ws_pos = find_cclass .CCLASS_WHITESPACE, str, peek_pos, $I0
    chunk_length = ws_pos - peek_pos
    follows_chunk = substr str, peek_pos, chunk_length
    $S0 = 'list element in quotes followed by "'
    $S0 .= follows_chunk
    $S0 .= '" instead of space'
    tcl_error $S0

found_close_quote:
    element_length = peek_pos - pos
    element_string = substr str,pos, element_length

    element_pmc = root_new ['parrot'; 'TclConst']
    element_pmc = element_string
    push retval, element_pmc
 
    pos = peek_pos + 1
    goto eat_space

done:
    .return(retval)
.end

=head2 getDictValue

=cut

.sub getDictValue :method
    # convert to list, then to dict.
    $P1 = self.'getListValue'()
    .tailcall $P1.'getDictValue'()
.end
