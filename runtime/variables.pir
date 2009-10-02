.HLL '_tcl'
.namespace []

=head2 Which level is which?

The call stack in parrot is similar to that of tcl, but they both use
slightly different numbering schemes to refer to the various levels.

Also, parrot may have additional levels present in the stack (like the helper
subs below) that should not be visible to the tcl user, but have to be taken
into account.

Parrot call stack level goes from 0 (current C<.sub>) up to :main (outermost).

Tcl's [upvar] and [uplevel] refer to levels in two ways:

=over 4

=item #0, #1, #2

0 indicates outermost scope (globals), up to the innermost
level (highest number)

=item 1, 2, 3

Like parrot's scheme: 1 is caller, 2 is caller's caller... (But only for
tcl levels.)

=back

[info level] uses a slightly different scheme

=over 4

=item 0, 1, 2

like upvar's #0, #1, #2

=item -1, -2, -3

like upvar's 1, 2, 3

=back

=cut

=head2 splitNamespace

Given a string namespace, return an array of names.

If a depth is passed in, the namespace from that point up the chain
is used instead of the current namespace.

=cut

.sub splitNamespace # XXX REVIEW
    .param string name
    .param int    depth     :optional
    .param int    has_depth :opt_flag

    .Unless(has_depth,{depth=0})

    .local pmc colons
    colons = get_root_global ['_tcl'], 'colons'

    .local pmc split
    split  = get_root_global ['parrot'; 'PGE'; 'Util'], 'split'

    .local pmc ns_name
    ns_name = split(colons, name)

    $I0 = elements ns_name
    if $I0 == 0 goto relative
    $S0 = ns_name[0]
    if $S0 != '' goto relative

absolute:
    $P1 = shift ns_name
    .return(ns_name)

relative:
    .interp()
relative_loop:
    inc depth
    $P0 = interp['sub'; depth]
    $P0 = $P0.'get_namespace'()
    $P0 = $P0.'get_name'()
    $S0 = $P0[0]
    if $S0 == '_tcl' goto relative_loop

    $I0 = elements $P0
    dec $I0
    .While($I0 != 0, {
        $P1 = $P0[$I0]
        unshift ns_name, $P1
        dec $I0
    })

    .return(ns_name)
.end

.sub getCallDepth # XXX REVIEW
    .local pmc call_chain
    call_chain = get_root_global ['_tcl'], 'call_chain'
    $I0 = elements call_chain
    .return($I0)
.end

.sub getLexPad # XXX REVIEW
    .param int depth
    .local pmc call_chain
    call_chain = get_root_global ['_tcl'], 'call_chain'
    $P1 = call_chain[depth]
    .return($P1)
.end

.sub runUpLevel # XXX REVIEW
    .param int parrot_level
    .param pmc tcl_code

    .local int rethrow_flag

    .local pmc compileTcl
    compileTcl = get_root_global ['_tcl'], 'compileTcl'

    .local pmc call_chain
    call_chain = get_root_global ['_tcl'], 'call_chain'

    .list(saved_call_chain)

    $I0 = 0
    .While($I0 != parrot_level, {
        $P0 = pop call_chain
        push saved_call_chain, $P0
        inc $I0
    })

    # if we get an exception, we have to reset the environment
    .local pmc retval
    push_eh restore_and_rethrow
        $P0 = compileTcl(tcl_code)
        retval = $P0()
    pop_eh

    rethrow_flag = 0
    goto restore

restore_and_rethrow:
    .catch()
    rethrow_flag = 1
    goto restore

restore:
    # restore the old level
    $I0 = 0
    .While($I0 != parrot_level, {
        $P0 = pop saved_call_chain
        push call_chain, $P0
        inc $I0
    })
    .IfElse(rethrow_flag, {
        .rethrow()
    },{
        retval = clone retval
        .return(retval)
    })
.end

=head2 getCallLevel

Take a string with a tcl-style level, ()
returns an int with the parrot level.
also return a boolean indicating whether or not we're just defaulting[0]

[0] code smell.

=cut

.sub getCallLevel # XXX REVIEW
    .param string tcl_level

    .int(defaulted,0)
    .int(parrot_level,0)

    .local int call_level
    call_level = getCallDepth()

    # starts with #, e.g. absolute level?
    $I1 = ord tcl_level
    .IfElse($I1==35, {
        $S0 = substr tcl_level, 1
        push_eh default
            parrot_level = toInteger($S0)
        pop_eh
    }, {
        push_eh default
            parrot_level = toInteger(tcl_level)
        pop_eh

        if parrot_level < 0 goto default_no_eh
        parrot_level = call_level - parrot_level
    })

    goto set

default:
    .catch()
default_no_eh:
    defaulted = 1
    parrot_level = call_level - 1

set:
    # Are we < 0 ?
    if parrot_level < 0          goto bad_level
    if parrot_level > call_level goto bad_level

    .return(parrot_level,defaulted)

bad_level:
   $S0 = tcl_level
   $S0 = 'bad level "' . $S0
   $S0 = $S0 . '"'
   tcl_error $S0
.end

=head2 readVar

Read a variable from its name. It may be a scalar or an
array.

Use the call level to determine if we are referring to a
global variable or a lexical variable

=cut

.sub readVar # XXX REVIEW
    .param string name

    .local pmc variable

    # is this an array?
    # ends with )
    .local int char
    char = ord name, -1
    if char != 41 goto scalar
    # contains a (
    char = index name, '('
    if char == -1 goto scalar

array:
    .local string var
    var = substr name, 0, char

    .local string key
    .local int len
    len = length name
    len -= char
    len -= 2
    inc char
    key = substr name, char, len

    variable = findVar(var)
    if null variable goto no_such_variable

    $I0 = does variable, 'associative_array'
    .Unless($I0, {
        $S0 =  "can't read \""
        $S0 .= name
        $S0 .= "\": variable isn't array"
        tcl_error $S0
    })

    variable = variable[key]
    if null variable goto bad_index
    $I0 = isa variable, 'Undef'
    if $I0 goto bad_index
    .return(variable)

bad_index:
    $S0 = "can't read \""
    $S0 .= name
    $S0 .= '": no such element in array'
    tcl_error $S0

scalar:
    variable = findVar(name)
    if null variable goto no_such_variable

    $I0 = does variable, 'associative_array'
    .If($I0, {
        $S0 = "can't read \""
        $S0 .= name
        $S0 .= '": variable is array'
        tcl_error $S0
    })
    .return(variable)

no_such_variable:
    $S0 = "can't read \""
    $S0 .= name
    $S0 .= '": no such variable'
    tcl_error $S0
.end

=head2 makeVar

Read a variable from its name. If it doesn't exist, create it. It may be a
scalar or an array.

Use the call level to determine if we are referring to a
global variable or a lexical variable - will no doubt
require further refinement later as we support namespaces
other than the default, and multiple interpreters.

=cut

.sub makeVar # XXX REVIEW
    .param string name
    .param int    depth :named('depth') :optional

    .local pmc variable

    # is this an array?
    # ends with )
    .local int char
    char = ord name, -1
    if char != 41 goto scalar
    # contains a (
    char = index name, '('
    if char == -1 goto scalar

array:
    .local string var
    var = substr name, 0, char

    .local string key
    .local int len
    len = length name
    len -= char
    len -= 2
    inc char
    key = substr name, char, len

    variable = findVar(var, 'depth' => depth)
    .If(null variable, {
        variable = new 'TclArray'
        variable = storeVar(var, variable, 'depth' => depth)
    })

    $I0 = does variable, 'associative_array'
    .Unless($I0, {
        $S0 =  "can't read \""
        $S0 .= name
        $S0 .= "\": variable isn't array"
        tcl_error $S0
    })

    $P0 = variable[key]
    .If(null $P0, {
        $P0 = new 'Undef'
        variable[key] = $P0
    })  
    .return($P0)

scalar:
    variable = findVar(name, 'depth' => depth)
    .If(null variable, {
        variable = new 'Undef'
        .tailcall storeVar(name, variable, 'depth' => depth)
    })
    .return(variable)
.end

=head2 setVar

Set a variable by its name. It may be a scalar or an array.

Use the call level to determine if we are referring to a
global variable or a lexical variable.

=cut

.sub setVar # XXX REVIEW
    .param string name
    .param pmc value

    .local pmc variable

    # Some cases in the code allow a NULL pmc to show up here.
    # This defensively converts them to an empty string.
    unless_null value, got_value
    value = box ''

got_value:
    # is this an array?
    # ends with )
    .local int char
    char = ord name, -1
    if char != 41 goto scalar
    # contains a (
    char = index name, '('
    if char == -1 goto scalar

find_array:
    .local string var
    var = substr name, 0, char

    .local string key
    .local int len
    len = length name
    len -= char
    len -= 2
    inc char
    key = substr name, char, len

    .local pmc array
    null array
    array = findVar(var)
    if null array goto create_array

    $I0 = does array, 'associative_array'
    unless $I0 goto cant_set_not_array
    goto set_array

create_array:
    array = new 'TclArray'
    array = storeVar(var, array)

set_array:
    variable = array[key]
    .IfElse(null variable, {
        array[key] = value
        .return(value)
    }, {
        assign variable, value
        .return(variable)
    })

cant_set_not_array:
    $S0 =  "can't set \""
    $S0 .= name
    $S0 .= "\": variable isn't array"
    tcl_error $S0

scalar:
    $P0 = findVar(name)
    if null $P0 goto create_scalar
    $I0 = does $P0, 'associative_array'
    if $I0 goto cant_set_array

create_scalar:
    .tailcall storeVar(name, value)

cant_set_array:
    $S0 =  "can't set \""
    $S0 .= name
    $S0 .= "\": variable is array"
    tcl_error $S0
.end

=head2 findVar

Utility function used by readVar and setVar.

Gets the actual variable from memory and returns it.

=cut

.sub findVar # XXX REVIEW
    .param string name
    .param int    isglobal :named('global') :optional
    .param int    depth    :named('depth')  :optional

    .local pmc value, ns

    .local int absolute
    absolute = 0

    $I0 = index name, '::'
    if $I0 == 0  goto absolute_global
    if $I0 != -1 goto global_var
    if isglobal  goto global_var

    .local int call_level
    call_level = getCallDepth()

    if call_level == 0 goto global_var

    name = '$' . name

    .local pmc lexpad, variable
    push_eh lexical_notfound
        lexpad = getLexPad(-1)
        value  = lexpad[name]
    pop_eh
    if null value goto args_check
    $I0 = isa value, 'Undef'
    if $I0 goto args_check
    goto found

args_check:
    # args is special -- it doesn't show up in [info vars]
    # unless you explicitly set it in your proc. but if you
    # try to get it, it's always there.
    unless name == '$args' goto notfound
    value = lexpad['args']
    .return(value)

absolute_global:
    absolute = 1
global_var:
    depth += 2
    ns = splitNamespace(name, depth)
    $S0 = pop ns
    $S0 = '$' . $S0

    unshift ns, 'tcl'
    ns = get_root_namespace ns
    if null ns goto notfound

    value = ns[$S0]
    if null value goto notfound
    $I0 = isa value, 'Undef'
    if $I0 goto notfound
    goto found

root_global_var:
    absolute = 1
    .local pmc colons, split
    colons = get_root_global ['_tcl'], 'colons'
    split  = get_root_global ['parrot'; 'PGE'; 'Util'], 'split'

    ns  = split(colons, name)
    $S0 = pop ns
    $S0 = '$' . $S0

    unshift ns, 'tcl'
    ns = get_root_namespace ns
    if null ns goto notfound

    value = ns[$S0]
    if null value goto found
    $I0 = isa value, 'Undef'
    if $I0 goto notfound
    goto found

notfound:
    unless absolute goto root_global_var
    null value
    .return(value)

lexical_notfound:
    .catch()
    null value
found:
    .return(value)
.end

=head2 storeVar

Utility function used by readVar and setVar.

Sets the actual variable from memory.

=cut

.sub storeVar # XXX REVIEW
    .param string name
    .param pmc    value
    .param int    isglobal :named('global') :optional
    .param int    depth    :named('depth')  :optional

    .local pmc ns

    $I0 = index name, '::'
    if $I0 != -1 goto global_var
    if isglobal goto global_var

    .local int call_level
    call_level = getCallDepth()
    if call_level == 0 goto global_var

    name = '$' . name
lexical_var:
    .local pmc lexpad
    lexpad = getLexPad(-1)

    $P0 = lexpad[name]
    if null $P0 goto lexical_is_null

    copy $P0, value
    .return($P0)

lexical_is_null:
    lexpad[name] = value
    .return(value)

global_var:
    depth += 2
    ns = splitNamespace(name, depth)
    .str(origName, name)
    name = pop ns
    name = '$' . name

    .iter(ns)
    .local pmc ns_cur
    ns_cur = get_root_namespace
    ns_cur = ns_cur['tcl']
    .While(iterator, {
        $S0 = shift iterator
        ns_cur = ns_cur[$S0]
        .If(null ns_cur, {
            $S0 = "can't set \""
            $S0 .= origName
            $S0 .= "\": parent namespace doesn't exist"
            tcl_error $S0
        })
    })
ns_loop:

    unshift ns, 'tcl'
    ns = get_root_namespace ns
    if null ns goto global_not_undef

   $P0 = ns[name]
   if null $P0 goto global_not_undef

   copy $P0, value
   .return($P0)

global_not_undef:
   ns[name] = value
   .return(value)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
