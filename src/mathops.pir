# ::tcl::mathop

.sub '&!'
    .param pmc argv :slurpy
    .argc()

    if argc != 1 goto bad_args

    $P1 = argv[0]
    push_eh bad_arg
        $I0 = isfalse $P1
    pop_eh

    .return($I0)

bad_arg:
    .catch()
    if $P1 == '' goto empty_string
    die "can't use non-numeric string as operand of \"!\""

empty_string:
    die "can't use empty string as operand of \"!\""

bad_args:
    die "wrong # args: should be \"! boolean\""
.end

.sub '&+'
    .param pmc argv :slurpy
    .argc()

     if argc == 0 goto nullary

     .local pmc toNumber
     toNumber = get_root_global ['_tcl'], 'toNumber'

    .local pmc iterator, arg
    iterator = iter argv
    .local pmc result
    result = new 'TclInt'
    result = 0
loop_begin:
    unless iterator goto loop_end
    arg = shift iterator
    push_eh bad_arg
        arg = toNumber(arg)
    pop_eh
    .if_nan(arg,nan)
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

nan:
    die "can't use non-numeric floating-point value as operand of \"+\""

 nullary:
    .return(0)
.end

.sub '&-'
    .param pmc argv :slurpy
    .argc()

     if argc < 1 goto bad_args

     .local pmc toNumber
     toNumber = get_root_global ['_tcl'], 'toNumber'

     .local pmc result
     result = shift argv
     push_eh bad_arg
         result = toNumber(result)
     pop_eh
     if argc == 1 goto unary

    .local pmc iterator, arg
    iterator = iter argv
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
    .catch()
    if arg == '' goto empty_string
    die "can't use non-numeric string as operand of \"-\""

empty_string:
    die "can't use empty string as operand of \"-\""

bad_args:
    die "wrong # args: should be \"- value ?value ...?\""
.end

.sub '&*'
    .param pmc argv :slurpy
    .argc()

     if argc == 0 goto nullary

     .local pmc toNumber
     toNumber = get_root_global ['_tcl'], 'toNumber'

    .local pmc iterator, arg
    iterator = iter argv
    .local pmc result
    result = new 'TclInt'
    result = 1
loop_begin:
    unless iterator goto loop_end
    arg = shift iterator
    push_eh bad_arg
        arg = toNumber(arg)
    pop_eh
    .if_nan(arg, nan)
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

nan:
    die "can't use non-numeric floating-point value as operand of \"*\""

 nullary:
    .return(1)
.end

.sub '&/'
    .param pmc argv :slurpy
    .argc()

     if argc < 1 goto bad_args

     .local pmc toNumber
     toNumber = get_root_global ['_tcl'], 'toNumber'

     .local pmc result
     result = shift argv
     push_eh bad_arg
         result = toNumber(result)
     pop_eh
     if argc == 1 goto unary

    .local pmc iterator, arg
    iterator = iter argv
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
    .catch()
    if arg == '' goto empty_string
    die "can't use non-numeric string as operand of \"/\""

empty_string:
    die "can't use empty string as operand of \"/\""

bad_args:
    die "wrong # args: should be \"/ value ?value ...?\""
.end

.sub '&%'
    .param pmc argv :slurpy
    .argc()

    if argc != 2 goto bad_args
    .local pmc a,b
    a = argv[0]
    b = argv[1]

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
    .catch()
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
    die "wrong # args: should be \"% integer integer\""
.end

.sub '&**'
    .param pmc argv :slurpy
    .argc()

     if argc == 0 goto nullary

     .local pmc toNumber
     toNumber = get_root_global ['_tcl'], 'toNumber'

    .local pmc result
    result = new 'TclInt'
    result = shift argv
    push_eh bad_arg
        result = toNumber(result)
    pop_eh

    if argc == 1 goto unary

    .local pmc iterator, arg
    iterator = iter argv
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
    .catch()
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
    .param pmc argv :slurpy
    .argc()

    if argc < 2 goto true

    .local pmc toNumber
    toNumber = get_root_global ['_tcl'], 'toNumber'


    .local pmc first,cur
    first = shift argv
    push_eh NaN
      first = toNumber(first)
NaN:
    pop_eh

    $P1 = iter argv
loop:
    unless $P1 goto true
    cur = shift $P1 
    push_eh NaN2
      cur = toNumber(cur)
NaN2:
    pop_eh
    if cur == first goto loop
    .return (0)
true: 

    .return(1)
.end

.sub '&eq'
    .param pmc argv :slurpy
    .argc()

    if argc < 2 goto true

    .local string first,cur
    first = shift argv

    $P1 = iter argv
loop:
    unless $P1 goto true
    cur = shift $P1 
    if cur == first goto loop
    .return (0)
true: 

    .return(1)
.end


.sub '&!='
    .param pmc argv :slurpy
    .argc()

    if argc != 2 goto bad_args

    .local pmc toNumber
    toNumber = get_root_global ['_tcl'], 'toNumber'

    .local pmc l,r
    l = shift argv
    r = shift argv
    push_eh NaN
      l = toNumber(l)
NaN:
    pop_eh
    push_eh NaN2
      r = toNumber(r)
NaN2:
    pop_eh

    if l != r goto true
    .return (0)
true: 
    .return(1)

bad_args:
    die 'wrong # args: should be "!= value value"'
.end

.sub '&ne'
    .param pmc argv :slurpy
    .argc()

    if argc != 2 goto bad_args

    .local pmc l,r
    l = shift argv
    r = shift argv

    if l != r goto true
    .return (0)
true: 
    .return(1)

bad_args:
    die 'wrong # args: should be "!= value value"'
.end

.sub '&<'
    .param pmc argv :slurpy
    .return(0)
.end

.sub '&<='
    .param pmc argv :slurpy
    .return(0)
.end

.sub '&>'
    .param pmc argv :slurpy
    .return(0)
.end

.sub '&>='
    .param pmc argv :slurpy
    .return(0)
.end

.sub '&~'
    .param pmc argv :slurpy
    .return(0)
.end

.sub '&&'
    .param pmc argv :slurpy
    .argc()

     if argc == 0 goto nullary

    .local pmc iterator, arg
    .local int arg_i
    iterator = iter argv
    .local int result
    result = -1
loop_begin:
    unless iterator goto loop_end
    arg = shift iterator
    push_eh bad_arg
        arg_i = arg
    pop_eh
    result = band result, arg_i
    goto loop_begin
loop_end:
    .return (result)

bad_arg:
    .catch()
    if arg == '' goto empty_string
    $S0 = exception
    $I0 = index $S0, 'invalid octal'
    if $I0 != -1 goto bad_octal_arg
     .local pmc toNumber
     toNumber = get_root_global ['_tcl'], 'toNumber'
    push_eh bad_string_arg
      toNumber(arg)       
    pop_eh 
    .if_nan(arg,nan)
    die "can't use floating-point value as operand of \"&\""

bad_string_arg:
    .catch()
    die "can't use non-numeric string as operand of \"&\""

bad_octal_arg:    
    die "can't use invalid octal number as operand of \"&\""

empty_string:
    die "can't use empty string as operand of \"&\""

nan:
    die "can't use non-numeric floating-point value as operand of \"&\""

 nullary:
    .return(-1)
.end

.sub '&|'
    .param pmc argv :slurpy
    .argc()

     if argc == 0 goto nullary

    .local pmc iterator, arg
    .local int arg_i
    iterator = iter argv
    .local int result
    result = 0
loop_begin:
    unless iterator goto loop_end
    arg = shift iterator
    push_eh bad_arg
        arg_i = arg
    pop_eh
    result = bor result, arg_i
    goto loop_begin
loop_end:
    .return (result)

bad_arg:
    .catch()
    if arg == '' goto empty_string
    $S0 = exception
    $I0 = index $S0, 'invalid octal'
    if $I0 != -1 goto bad_octal_arg
     .local pmc toNumber
     toNumber = get_root_global ['_tcl'], 'toNumber'
    push_eh bad_string_arg
      toNumber(arg)       
    pop_eh 
    .if_nan(arg,nan)
    die "can't use floating-point value as operand of \"|\""

bad_string_arg:
    .catch()
    die "can't use non-numeric string as operand of \"|\""

bad_octal_arg:    
    die "can't use invalid octal number as operand of \"|\""

empty_string:
    die "can't use empty string as operand of \"|\""

nan:
    die "can't use non-numeric floating-point value as operand of \"|\""

 nullary:
    .return(0)
.end

.sub '&^'
    .param pmc argv :slurpy
    .argc()

     if argc == 0 goto nullary

    .local pmc iterator, arg
    .local int arg_i
    iterator = iter argv
    .local int result
    result = 0
loop_begin:
    unless iterator goto loop_end
    arg = shift iterator
    push_eh bad_arg
        arg_i = arg
    pop_eh
    result = bxor result, arg_i
    goto loop_begin
loop_end:
    .return (result)

bad_arg:
    .catch()
    if arg == '' goto empty_string
    $S0 = exception
    $I0 = index $S0, 'invalid octal'
    if $I0 != -1 goto bad_octal_arg
     .local pmc toNumber
     toNumber = get_root_global ['_tcl'], 'toNumber'
    push_eh bad_string_arg
      toNumber(arg)       
    pop_eh 
    .if_nan(arg,nan)
    die "can't use floating-point value as operand of \"^\""

bad_string_arg:
    .catch()
    die "can't use non-numeric string as operand of \"^\""

bad_octal_arg:    
    die "can't use invalid octal number as operand of \"^\""

empty_string:
    die "can't use empty string as operand of \"^\""

nan:
    die "can't use non-numeric floating-point value as operand of \"^\""

 nullary:
    .return(0)
.end

.sub '&<<'
    .param pmc argv :slurpy
    .return(0)
.end

.sub '&>>'
    .param pmc argv :slurpy
    .return(0)
.end

.sub '&in'
    .param pmc argv :slurpy
    .return(0)
.end

.sub '&ni'
    .param pmc argv :slurpy
    .return(0)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:

