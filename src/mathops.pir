# ::tcl::mathop

.sub '&!'
    .param pmc args :slurpy

    .local int argc
    argc = args

    if argc != 1 goto bad_args

    .local pmc toBoolean
    toBoolean = get_root_global ['_tcl'], 'toBoolean'
    $P1 = args[0]
    push_eh bad_arg
        $P1 = toBoolean($P1)
    pop_eh
    $I0 = $P1
    $I0 = not $I0
    .return($I0)

bad_arg:
    if $P1 == '' goto empty_string
    die "can't use non-numeric string as operand of \"!\""

empty_string:
    die "can't use empty string as operand of \"!\""

bad_args:
    die "wrong # args: should be \"::tcl::mathop::! boolean\""
.end

.sub '&+'
    .param pmc args :slurpy

     .local int argc
     argc = args
     if argc == 0 goto nullary

     .local pmc toNumber
     toNumber = get_root_global ['_tcl'], 'toNumber'

    .local pmc iterator, arg
    iterator = iter args
    .local pmc result
    result = new 'TclInt'
    result = 0
loop_begin:
    unless iterator goto loop_end
    arg = shift iterator
    push_eh bad_arg
        arg = toNumber(arg)
    pop_eh
    result += arg
    goto loop_begin
loop_end:
    .return (result)

bad_arg:
    .catch()
    if arg == '' goto empty_string
    $S0 = exception
    $I0 = index $S0, 'invalid octal'
    if $I0 != -1 goto bad_octal_arg
    die "can't use non-numeric string as operand of \"+\""

bad_octal_arg:    
    die "can't use invalid octal number as operand of \"+\""

empty_string:
    die "can't use empty string as operand of \"+\""

 nullary:
    .return(0)
.end

.sub '&-'
    .param pmc args :slurpy

     .local int argc
     argc = args
     if argc < 1 goto bad_args

     .local pmc toNumber
     toNumber = get_root_global ['_tcl'], 'toNumber'

     .local pmc result
     result = shift args
     push_eh bad_arg
         result = toNumber(result)
     pop_eh
     if argc == 1 goto unary

    .local pmc iterator, arg
    iterator = iter args
    .local pmc result
loop_begin:
    unless iterator goto loop_end
    arg = shift iterator
    push_eh bad_arg
        arg = toNumber(arg)
    pop_eh
    result = result - arg
    goto loop_begin
loop_end:
    .return (result)

unary:
    result =- result
    .return (result)

bad_arg:
    if arg == '' goto empty_string
    die "can't use non-numeric string as operand of \"-\""

empty_string:
    die "can't use empty string as operand of \"-\""

bad_args:
    die "wrong # args: should be \"::tcl::mathop::- value ?value ...?\""
.end

.sub '&*'
    .param pmc args :slurpy

     .local int argc
     argc = args
     if argc == 0 goto nullary

     .local pmc toNumber
     toNumber = get_root_global ['_tcl'], 'toNumber'

    .local pmc iterator, arg
    iterator = iter args
    .local pmc result
    result = new 'TclInt'
    result = 1
loop_begin:
    unless iterator goto loop_end
    arg = shift iterator
    push_eh bad_arg
        arg = toNumber(arg)
    pop_eh
    result *= arg
    goto loop_begin
loop_end:
    .return (result)

bad_arg:
    .catch()
    $S0 = exception
    $I0 = index $S0, 'invalid octal'
    if $I0 != -1 goto bad_octal_arg
    die "can't use non-numeric string as operand of \"*\""

bad_octal_arg:
    die "can't use invalid octal number as operand of \"*\""

 nullary:
    .return(1)
.end

.sub '&/'
    .param pmc args :slurpy

     .local int argc
     argc = args
     if argc < 1 goto bad_args

     .local pmc toNumber
     toNumber = get_root_global ['_tcl'], 'toNumber'

     .local pmc result
     result = shift args
     push_eh bad_arg
         result = toNumber(result)
     pop_eh
     if argc == 1 goto unary

    .local pmc iterator, arg
    iterator = iter args
    .local pmc result
loop_begin:
    unless iterator goto loop_end
    arg = shift iterator
    push_eh bad_arg
        arg = toNumber(arg)
    pop_eh
    result = result / arg
    goto loop_begin
loop_end:
    .return (result)

unary:
    $P1 = new 'TclFloat'
    $P1 = 1.0
    $P1 /= result
    .return ($P1)

bad_arg:
    if arg == '' goto empty_string
    die "can't use non-numeric string as operand of \"/\""

empty_string:
    die "can't use empty string as operand of \"/\""

bad_args:
    die "wrong # args: should be \"::tcl::mathop::/ value ?value ...?\""
.end

.sub '&%'
    .param pmc args :slurpy

    .local int argc
    argc = args
    if argc != 2 goto bad_args
    .local pmc a,b
    a = args[0]
    b = args[1]

    .local pmc toNumber
    toNumber = get_root_global ['_tcl'], 'toNumber'

    push_eh is_string
      a = toNumber(a)
      b = toNumber(b)
    pop_eh

    if b == 0 goto divide_by_zero

    $I0 = isa a, 'TclFloat'
    if $I0 goto is_float
    $I0 = isa b, 'TclFloat'
    if $I0 goto is_float

    $P0 = new 'TclInt'
    $P0 = mod a, b
    .return($P0)

is_string:
    if a == '' goto empty_string
    if b == '' goto empty_string
    die "can't use non-numeric string as operand of \"%\""

empty_string:
    die "can't use empty string as operand of \"%\""

is_float:
    die "can't use floating-point value as operand of \"%\""

divide_by_zero:
    die "divide by zero"

bad_args:
    die "wrong # args: should be \"::tcl::mathop::% integer integer\""
.end

.sub '&**'
    .param pmc args :slurpy

     .local int argc
     argc = args
     if argc == 0 goto nullary

     .local pmc toNumber
     toNumber = get_root_global ['_tcl'], 'toNumber'

    .local pmc result
    result = new 'TclInt'
    result = shift args
    push_eh bad_arg
        result = toNumber(result)
    pop_eh

    if argc == 1 goto unary

    .local pmc iterator, arg
    iterator = iter args
loop_begin:
    unless iterator goto loop_end
    arg = shift iterator
    push_eh bad_arg
        arg = toNumber(arg)
    pop_eh
    result = result ** arg
    goto loop_begin
loop_end:
    .return (result)

bad_arg:
    if arg == '' goto empty_string
    die "can't use non-numeric string as operand of \"**\""

empty_string:
    die "can't use empty string as operand of \"**\""

 nullary:
    .return(1)

unary:
    .return(result)
.end

.sub '&=='
    .param pmc args :slurpy

    .local int argc
    argc = args
    if argc < 2 goto true

    .local pmc toNumber
    toNumber = get_root_global ['_tcl'], 'toNumber'


    .local pmc first,cur
    first = shift args
    push_eh NaN
      first = toNumber(first)
    pop_eh
NaN:

    $P1 = iter args
loop:
    unless $P1 goto true
    cur = shift $P1 
    push_eh NaN2
      cur = toNumber(cur)
    pop_eh
NaN2:
    if cur == first goto loop
    .return (0)
true: 

    .return(1)
.end

.sub '&eq'
    .param pmc args :slurpy

    .local int argc
    argc = args
    if argc < 2 goto true

    .local string first,cur
    first = shift args

    $P1 = iter args
loop:
    unless $P1 goto true
    cur = shift $P1 
    if cur == first goto loop
    .return (0)
true: 

    .return(1)
.end


.sub '&!='
    .param pmc args :slurpy

    .local int argc
    argc = args
    if argc != 2 goto bad_args

    .local pmc toNumber
    toNumber = get_root_global ['_tcl'], 'toNumber'

    .local pmc l,r
    l = shift args
    r = shift args
    push_eh NaN
      l = toNumber(l)
    pop_eh
NaN:
    push_eh NaN2
      r = toNumber(r)
    pop_eh
NaN2:

    if l != r goto true
    .return (0)
true: 
    .return(1)

bad_args:
    die 'wrong # args: should be "::tcl::mathop::!= value value"'
.end

.sub '&ne'
    .param pmc args :slurpy

    .local int argc
    argc = args
    if argc != 2 goto bad_args

    .local pmc l,r
    l = shift args
    r = shift args

    if l != r goto true
    .return (0)
true: 
    .return(1)

bad_args:
    die 'wrong # args: should be "::tcl::mathop::!= value value"'
.end

.sub '&<'
    .param pmc args :slurpy
    .return(0)
.end

.sub '&<='
    .param pmc args :slurpy
    .return(0)
.end

.sub '&>'
    .param pmc args :slurpy
    .return(0)
.end

.sub '&>='
    .param pmc args :slurpy
    .return(0)
.end

.sub '&~'
    .param pmc args :slurpy
    .return(0)
.end

.sub '&&'
    .param pmc args :slurpy
    .return(0)
.end

.sub '&|'
    .param pmc args :slurpy
    .return(0)
.end

.sub '&<<'
    .param pmc args :slurpy
    .return(0)
.end

.sub '&>>'
    .param pmc args :slurpy
    .return(0)
.end

.sub '&in'
    .param pmc args :slurpy
    .return(0)
.end

.sub '&ni'
    .param pmc args :slurpy
    .return(0)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

