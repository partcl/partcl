.HLL 'tcl'
.namespace []

.sub 'string_options' :anon :immediate
    .local pmc opts
    opts = split ' ', 'bytelength compare equal first index is last length map match range repeat replace reverse tolower toupper totitle trim trimleft trimright wordend wordstart'

    .return(opts)
.end

.sub 'string_classes' :anon :immediate
    .local pmc classes
    classes = split ' ', 'alnum alpha ascii control boolean digit double false graph integer list lower print punct space true upper wideinteger wordchar xdigit'
    .return(classes)
.end

.sub '&string'
    .param pmc argv :slurpy

    .int(argc, elements argv)
    .Unless(argc, {
        die 'wrong # args: should be "string subcommand ?argument ...?"'
    })

    .local string subcommand
    subcommand = shift argv
    dec argc

    .const 'Sub' options = 'string_options'

    .local pmc select_option
    select_option  = get_root_global ['_tcl'], 'select_option'

    subcommand = select_option(options, subcommand)

    .If(subcommand == 'first', {
        .int(args_ok, 1)
        .If(argc <2, {args_ok = 0})
        .If(argc >3, {args_ok = 0})
        .Unless(args_ok, {
            die 'wrong # args: should be "string first needleString haystackString ?startIndex?"'
        })

        .str(needle,   argv[0])
        .str(haystack, argv[1])
        .int(pos, 0)
        .Unless(argc==2, {
            .str(pos_s, argv[2])
            .local pmc getIndex
            getIndex = get_root_global ['_tcl'], 'getIndex'
            pos = getIndex(pos_s, haystack)
            .If(pos <=0, {pos = 0})
        })

        .local int index_1
        index_1 = index haystack, needle, pos
        .return(index_1)
    })

    .If(subcommand == 'last', {
        .int(args_ok, 1)
        .If(argc > 3, {args_ok = 0})
        .If(argc < 2, {args_ok = 0})
        .Unless(args_ok, {
            die 'wrong # args: should be "string last needleString haystackString ?startIndex?"'
        })

        .str(needle,   argv[0])
        .str(haystack, argv[1])
        .int(start_pos, {length haystack})

        .If(argc == 3, {
            .str(index_s, argv[2])

            .local pmc getIndex
            getIndex = get_root_global ['_tcl'], 'getIndex'

            $I0 = getIndex(index_s, haystack)
            .If($I0 <= start_pos, {
                start_pos = $I0
            })
        })

        # XXX This algorithm loops through from string start -
        # Does parrot provide a more natural way to do this?

        .local int cur_pos
        cur_pos = index haystack, needle, 0
        .If(cur_pos > start_pos, {
           .return(-1)
        })
        .If(cur_pos < 0, {
            .return(-1)
        })

        .Loop({
            $I1 = cur_pos
            $I2 = $I1 + 1
            cur_pos = index haystack, needle, $I2
            if cur_pos < 0 goto return
            if cur_pos > start_pos goto return
        })

    return:
        .return($I1)
    })

    .If(subcommand == 'index', {
        .If(argc != 2, {
            die 'wrong # args: should be "string index string charIndex"'
        })

        .str(index_s,  argv[0])
        .str(string_s, argv[1])

        .local pmc getIndex
        getIndex = get_root_global ['_tcl'], 'getIndex'

        .int(pos, {getIndex(string_s, index_s)})

        .If(pos < 0, {
            .return('')
        })

        .int(strlen, length string_s)
        inc strlen

        .If(pos > strlen, {
            .return('')
        })

        $S0 = substr index_s, pos, 1
        .return ($S0)
    })

    .If(subcommand == 'tolower', {
        .int(args_ok, 1)
        .If(argc > 3, {args_ok = 0})
        .If(argc < 1, {args_ok = 0})
        .Unless(args_ok, {
            die 'wrong # args: should be "string tolower string ?first? ?last?"'
        })

        .str(orig_str, argv[0])
        .int(orig_len, length orig_str)

        # If no range is specified, do to all the string
        .int(first_i, 0)
        .int(last_i,  orig_len)

        .If(argc > 1, {
            .local pmc getIndex
            getIndex = get_root_global ['_tcl'], 'getIndex'

            .str(first_s, argv[1])
            first_i = getIndex(first_s, orig_str)
            # if just the first is specified, the last is the same
            last_i = first_i
            .If(argc != 2, {
                .str(last_s, argv[2])
                last_i = getIndex(last_s, orig_str)
            })
        })

        .If(first_i > orig_len, {
            .return(orig_str)
        })
        .If(last_i > orig_len, {last_i = orig_len})

        .int(chunk_len, last_i)
        chunk_len -= first_i
        chunk_len += 1

        .str(portion, {substr orig_str, first_i, chunk_len})
        downcase portion
        substr orig_str, first_i, chunk_len, portion

        .return(orig_str)
    })

    .If(subcommand == 'toupper', {
        .int(args_ok, 1)
        .If(argc > 3, {args_ok = 0})
        .If(argc < 1, {args_ok = 0})
        .Unless(args_ok, {
            die 'wrong # args: should be "string toupper string ?first? ?last?"'
        })

        .str(orig_str, argv[0])
        .int(orig_len, length orig_str)

        # If no range is specified, do to all the string
        .int(first_i, 0)
        .int(last_i,  orig_len)

        .If(argc > 1, {
            .local pmc getIndex
            getIndex = get_root_global ['_tcl'], 'getIndex'

            .str(first_s, argv[1])
            first_i = getIndex(first_s, orig_str)
            # if just the first is specified, the last is the same
            last_i = first_i
            .If(argc != 2, {
                .str(last_s, argv[2])
                last_i = getIndex(last_s, orig_str)
            })
        })

        .If(first_i > orig_len, {
                .return(orig_str)
        })
        .If(last_i > orig_len, {last_i = orig_len})

        .int(chunk_len, last_i)
        chunk_len -= first_i
        chunk_len += 1

        .str(portion, {substr orig_str, first_i, chunk_len})
        upcase portion
        substr orig_str, first_i, chunk_len, portion

        .return(orig_str)
    })

    .If(subcommand == 'totitle', {
        .int(args_ok, 1)
        .If(argc > 3, {args_ok = 0})
        .If(argc < 1, {args_ok = 0})
        .Unless(args_ok, {
            die 'wrong # args: should be "string totitle string ?first? ?last?"'
        })

        .str(orig_str, argv[0])
        .int(orig_len, length orig_str)

        # If no range is specified, do to all the string
        .int(first_i, 0)
        .int(last_i,  orig_len)

        .If(argc > 1, {
            .local pmc getIndex
            getIndex = get_root_global ['_tcl'], 'getIndex'

            .str(first_s, argv[1])
            first_i = getIndex(first_s, orig_str)
            # if just the first is specified, the last is the same
            last_i = first_i
            .If(argc != 2, {
                .str(last_s, argv[2])
                last_i = getIndex(last_s, orig_str)
            })
        })

        .If(first_i > orig_len, {
                .return(orig_str)
        })
        .If(last_i > orig_len, {last_i = orig_len})

        .int(chunk_len, last_i)
        chunk_len -= first_i
        chunk_len += 1

        .str(portion, {substr orig_str, first_i, chunk_len})
        titlecase portion
        substr orig_str, first_i, chunk_len, portion

        .return(orig_str)
    })

    .If(subcommand == 'bytelength', {
        .If(argc != 1, {
            die 'wrong # args: should be "string bytelength string"'
        })

        $S0 = argv[0]
        $I0 = bytelength $S0
        .return($I0)
    })

    .If(subcommand == 'length', {
        .If(argc != 1, {
            die 'wrong # args: should be "string length string"'
        })

        $S1 = argv[0]
        $I0 = length $S1
        .return($I0)
    })

    .If(subcommand == 'range', {
        .If(argc !=3, {
            die 'wrong # args: should be "string range string first last"'
        })

        .local string teh_string, first_s, last_s, result
        teh_string = shift argv
        result = '' # default result
        first_s = shift argv
        last_s  = shift argv

        .local int last_index
        last_index = length teh_string
        dec last_index

        .local pmc getIndex
        getIndex = get_root_global ['_tcl'], 'getIndex'

        .local int first_i, last_i
        first_i = getIndex(first_s, teh_string)
        last_i  = getIndex(last_s, teh_string)

        if first_i > last_i goto done

        if first_i >= 0  goto range_top
        first_i = 0
    range_top:
        if last_i <= last_index goto range_do
        last_i = last_index
    range_do:
        .local int repl_len
        repl_len = last_i - first_i
        inc repl_len

        result = substr teh_string, first_i, repl_len

    done:
        .return(result)
    })

    .If(subcommand == 'match', {
        .int(args_ok, 1)
        .If(argc < 2, {args_ok =0})
        .If(argc > 3, {args_ok =0})
        .Unless(args_ok, {
            die 'wrong # args: should be "string match ?-nocase? pattern string"'
        })

        .int(nocase, 0)
        if argc == 2 goto match_next
        $S0 = shift argv
        if $S0 == '-nocase' goto set_nocase
        if $S0 == '-nocas' goto set_nocase
        if $S0 == '-noca' goto set_nocase
        if $S0 == '-noc' goto set_nocase
        if $S0 == '-no' goto set_nocase
        if $S0 == '-n' goto set_nocase
        goto bad_option

    set_nocase:
        nocase = 1

    match_next:
        .local string pattern
        .local string the_string

        pattern = argv[0]
        the_string = argv[1]
        unless nocase goto match_continue
        pattern = downcase pattern

        the_string = downcase the_string

    match_continue:
        .local pmc globber
        globber = compreg 'Tcl::Glob'

        .local pmc rule, match
        rule = globber.'compile'(pattern)
        match = rule(the_string)

        $I0 = istrue match
        .return ($I0)

    bad_option:
        $S1 = 'bad option "'
        $S1 .= $S0
        $S1 .= '": must be -nocase'
        die $S1
    })

    .If(subcommand == 'repeat', {
        .If(argc != 2, {
            die 'wrong # args: should be "string repeat string count"'
        })

        .local string the_string
        .local pmc    the_repeat
        the_string = argv[0]
        the_repeat = argv[1]

        .local pmc toInteger
        toInteger = get_root_global ['_tcl'], 'toInteger'
        the_repeat = toInteger(the_repeat)

        $I0 = the_repeat
        .If($I0 <= 0, {
            .return('')
        })
        $S0 = repeat the_string, $I0
        .return($S0)
    })

    .If(subcommand == 'map', {
        .int(args_ok, 1)
        .If(argc == 0, {args_ok = 0})
        .If(argc > 3,  {args_ok = 0})
        .Unless(args_ok, {
            die 'wrong # args: should be "string map ?-nocase? charMap string"'
        })

        .int(nocase, 0)
        if argc == 2 goto setup
        $S0 = shift argv
        if $S0 != '-nocase' goto bad_option2
        nocase = 1

    setup:
        .local string the_string,mapstr,teststr,replacementstr
        .local pmc map_list
        .local int strpos,strlen,mappos,maplen,skiplen,mapstrlen,replacementstrlen

        $P0 = argv[0]
        map_list = $P0.'getListValue'()
        the_string = argv[1]

        maplen = map_list
        $I1 = maplen % 2
        if $I1 goto oddly_enough

        strpos = 0

    outer_loop:
        strlen = length the_string
        if strpos >= strlen goto outer_done
        skiplen = 1
        mappos = 0

    inner_loop:
        if mappos >= maplen goto inner_done
        mapstr = map_list[mappos]
        mapstrlen = length mapstr
        if mapstrlen == 0 goto inner_next

        teststr = substr the_string, strpos, mapstrlen
        # if nocase, tweak 'em both to lc.
        if nocase == 0 goto test
        downcase teststr
        downcase mapstr
    test:
        if teststr != mapstr goto inner_next
        $I0 = mappos + 1
        replacementstr = map_list [ $I0 ]
        substr the_string, strpos, mapstrlen,replacementstr
        skiplen = length replacementstr
        goto outer_next

    inner_next:
        mappos += 2
        goto inner_loop

    inner_done:
    outer_next:
        strpos += skiplen
        goto outer_loop

    outer_done:
        .return (the_string)

    oddly_enough:
        die 'char map list unbalanced'

    bad_option2:
        $S1 = 'bad option "'
        $S1 .= $S0
        $S1 .= '": must be -nocase'
        die $S1
    })

    .If(subcommand == 'equal', {
        .local string a, b
        .local int len, nocase
        nocase = 0
        len = -1

        if argc < 2 goto bad_args
        if argc == 2 goto flags_done

        .local string flag
    flag_loop:
        flag = shift argv
        if flag == '-length' goto got_length
        if flag == '-nocase' goto got_nocase
        branch bad_args

    got_length:
        len = shift argv
        branch gotten
    got_nocase:
        nocase = 1
    gotten:

        argc = elements argv
        if argc == 2 goto flags_done
        if argc < 2 goto bad_args
        branch flag_loop
    flag_end:

    flags_done:
        a = shift argv
        b = shift argv

        unless nocase goto skip_lower
        downcase a
        downcase b
    skip_lower:

        if len == -1 goto skip_shorten
        a = substr a, 0, len
        b = substr b, 0, len
    skip_shorten:

    check:
        .If(a == b, {
                .return(1)
        })
        .return (0)

    bad_args:
        die 'wrong # args: should be "string equal ?-nocase? ?-length int? string1 string2"'
    })

    .If(subcommand == 'is', {
        if argc < 2 goto bad_args2

        .local pmc toNumber
        .local int strict
        strict = 0

        .local int the_cclass

        .local string class
        class = shift argv

        .local pmc select_option
        select_option  = get_root_global ['_tcl'], 'select_option'

        .const 'Sub' classes = 'string_classes'
        class = select_option(classes, class, 'class')

        .local int strict
        strict = 0

        argc = argv
        if argc == 1 goto no_opts

        .local pmc options
        options = new 'TclList'
        push options, 'strict'
        push options, 'failindex'

        .local pmc select_switches, switches
        select_switches  = get_root_global ['_tcl'], 'select_switches'
        switches = select_switches(options, argv, 'catchbad' => 1, 'name'=>'option')

        strict = exists options['strict']

    no_opts:
        .local string the_string
        .local pmc pmc_string
        pmc_string = shift argv
        the_string = pmc_string

        if the_string != '' goto not_empty
        $I0 = not strict
        .return ($I0)

    not_empty:


        if class == 'alnum' goto alnum_check
        if class == 'alpha' goto alpha_check
        if class == 'ascii' goto ascii_check
        if class == 'control' goto control_check
        if class == 'boolean' goto boolean_check
        if class == 'digit' goto digit_check
        if class == 'double' goto double_check
        if class == 'false' goto false_check
        if class == 'graph' goto graph_check
        if class == 'integer' goto integer_check
        if class == 'list' goto list_check
        if class == 'lower' goto lower_check
        if class == 'print' goto print_check
        if class == 'punct' goto punct_check
        if class == 'space' goto space_check
        if class == 'true' goto true_check
        if class == 'upper' goto upper_check
        if class == 'wideinteger' goto integer_check # XXX implement this check
        if class == 'wordchar' goto wordchar_check
        if class == 'xdigit' goto xdigit_check

    alnum_check:
        the_cclass = .CCLASS_ALPHANUMERIC
        goto cclass_check
    alpha_check:
        the_cclass = .CCLASS_ALPHABETIC
        goto cclass_check
    ascii_check:
        .int(pos, 0)
	.int(strlen, length the_string)
	.While(pos < strlen, {
            $I0 = ord the_string, pos
	    .If($I0 > 255, { .return(0) })
	    inc pos
	})
        .return(1)
    control_check:
        the_cclass = .CCLASS_CONTROL
        goto cclass_check
    boolean_check:
        .TryCatch({
            $I0 = istrue pmc_string
            .return(1)
	}, {
            .return(0)
	})
    digit_check:
        the_cclass = .CCLASS_NUMERIC
        goto cclass_check
    double_check:
        toNumber = get_root_global ['_tcl'], 'toNumber'
        push_eh nope_eh
            $P2 = toNumber(the_string)
        pop_eh

        $S0 = typeof $P2
        if $S0 == 'TclFloat' goto yep
        if $S0 == 'TclInt'   goto yep
        goto nope
    false_check:
        .TryCatch({
            $I0 = isfalse pmc_string
            .return($I0)
	}, {
            .return(0)
	})
    graph_check:
        the_cclass = .CCLASS_GRAPHICAL
        goto cclass_check
    integer_check:
        toNumber = get_root_global ['_tcl'], 'toNumber'
        push_eh nope_eh
            $P2 = toNumber(the_string)
        pop_eh

        $S0 = typeof $P2
        if $S0 == 'TclInt' goto yep
        goto nope
    list_check:
        $P0 = box the_string
        push_eh nope_eh
            $P0.'getListValue'()
        pop_eh
        goto yep
    lower_check:
        the_cclass = .CCLASS_LOWERCASE
        goto cclass_check
    print_check:
        the_cclass = .CCLASS_PRINTING
        goto cclass_check
    punct_check:
        the_cclass = .CCLASS_PUNCTUATION
        goto cclass_check
    space_check:
        the_cclass = .CCLASS_WHITESPACE
        goto cclass_check
    true_check:
        .TryCatch({
            $I0 = istrue pmc_string
            .return($I0)
	}, {
            .return(0)
	})
    upper_check:
        the_cclass = .CCLASS_UPPERCASE
        goto cclass_check
    wordchar_check:
        the_cclass = .CCLASS_WORD
        goto cclass_check
    xdigit_check:
        the_cclass = .CCLASS_HEXADECIMAL
        goto cclass_check

    cclass_check:
        # Loop over the string. Die immediately if we fail.
        # RT#40773: Tie the index of the string into --failvar
        .local int len,ii
        len = length the_string
        ii = 0
    loop:
        if ii == len goto yep
        $I0 = is_cclass the_cclass, the_string, ii
        unless $I0 goto nope
        inc ii
        goto loop

    yep:
        .return(1)

    nope_eh:
        .catch()
    nope:
        .return(0)

    bad_args2:
         die 'wrong # args: should be "string is class ?-strict? ?-failindex var? str"'
    })

    .If(subcommand == 'replace', {


        .int(args_ok, 1)
        .If(argc > 4, {args_ok = 0})
        .If(argc < 3, {args_ok = 0})
        .Unless(args_ok, {
            die 'wrong # args: should be "string replace string first last ?string?"'
        })

        .local int low
        .local int high
        .local int len

        .local pmc getIndex
        getIndex = get_root_global ['_tcl'], 'getIndex'

        .local string low_s, high_s, the_string
        .local int string_len

        the_string = argv[0]
        string_len = length the_string
        $S4 = ''

        low_s = argv[1]
        low = getIndex(low_s, the_string)

        if low >= string_len goto replace_done

        high_s = argv[2]
        high = getIndex(high_s, the_string)

        if high < low goto replace_done

        if low >= 0 goto low_ok
        low = 0

    low_ok:
        len = length the_string
        if high <= len goto high_ok
        high = len

    high_ok:
        if argc == 1 goto replace_do
        $S4 = argv[3]

    replace_do:
        len = high - low
        len += 1
        substr the_string, low, len, $S4

    replace_done:
        .return(the_string)

    })


    .If(subcommand == 'trimleft', {
        .int(args_ok, 1)
        .If(argc > 2, {args_ok =0})
        .If(argc < 1, {args_ok =0})
        .Unless(args_ok, {
            die 'wrong # args: should be "string trimleft string ?chars?"'
        })

        $S1 = argv[0]
        $S2 = " \t\r\n"

        if argc == 1 goto trimleft_do

        $S2 = argv[1]

    trimleft_do:
        .local string char
        $I1 = length $S1
        unless $I1 goto trimleft_done

        char = substr $S1, 0, 1
        $I1 = index $S2, char

        if $I1 < 0 goto trimleft_done
        substr $S1, 0, 1, ''
        goto trimleft_do

    trimleft_done:
        .return($S1)
    })

    .If(subcommand == 'trimright', {
        .int(args_ok, 1)
        .If(argc > 2, {args_ok = 0})
        .If(argc < 1, {args_ok = 0})
        .Unless(args_ok, {
            die 'wrong # args: should be "string trimright string ?chars?"'
        })

        $S1 = argv[0]
        $S2 = " \t\r\n"

        if argc == 1 goto trimright_do

        $S2 = argv[1]

    trimright_do:
        .local string char
        $I1 = length $S1
        unless $I1 goto trimright_done

        char = substr $S1, -1, 1
        $I1 = index $S2, char

        if $I1 < 0 goto trimright_done
        chopn $S1, 1
        goto trimright_do

    trimright_done:
        .return($S1)
    })

    .If(subcommand == 'trim', {
        .int(args_ok, 1)
        .If(argc > 2, {args_ok = 0})
        .If(argc < 1, {args_ok = 0})
        .Unless(args_ok, {
            die 'wrong # args: should be "string trim string ?chars?"'
        })

        $S1 = argv[0]
        $S2 = " \t\r\n"

        if argc == 1 goto trim_do1

        $S2 = argv[1]

    trim_do1:
        .local string char

        $I1 = length $S1
        unless $I1 goto trim_do2

        char = substr $S1, -1, 1
        $I1 = index $S2, char

        if $I1 < 0 goto trim_do2
        chopn $S1, 1
        goto trim_do1

    trim_do2:
        $I1 = length $S1
        unless $I1 goto trim_done

        char = substr $S1, 0, 1
        $I1 = index $S2, char

        if $I1 < 0 goto trim_done
        substr $S1, 0, 1, ''
        goto trim_do2

    trim_done:
        .return($S1)
    })

    .If(subcommand == 'compare', {
        if argc <1 goto bad_args3

        .local int size
        size = -1

        $S2 = pop argv
        $S1 = pop argv

    args_processment:
        argc = elements argv
        if argc == 0 goto args_processed
        $S4 = shift argv
        if $S4 == '-nocase' goto arg_nocase
        if $S4 == '-length' goto arg_length
        goto bad_args3

    args_processed:
        if $S1 == $S2 goto equal
        if $S1 < $S2 goto smaller
        .return(1)

    smaller:
        .return(-1)

    equal:
        .return(0)

    arg_nocase:
        downcase $S1
        downcase $S2
        goto args_processment

    arg_length:
        if size != -1 goto bad_args3
        argc = elements argv
        if argc == 0 goto bad_args3

        .local pmc toInteger
        toInteger = get_root_global ['_tcl'], 'toInteger'
        $S4  = shift argv
        size = toInteger($S4)
        # "if -length is negative, it is ignored"
        if size < 0 goto args_processment
        $S1 = substr $S1, 0, size
        $S2 = substr $S2, 0, size
        goto args_processment

    bad_args3:
        die 'wrong # args: should be "string compare ?-nocase? ?-length int? string1 string2"'
    })

    .If(subcommand == 'reverse', {
        .If(argc !=1, {
            die 'wrong # args: should be "string reverse string"'
        })

        $S0 = shift argv
        $P0 = new 'TclString'
        $S0 = $P0.'reverse'($S0)
        .return ($S0)
    })

    .If(subcommand == 'wordend', {
        .If(argc != 2, {
            die 'wrong # args: should be "string wordend string index"'
        })

        .local string str
        .local int    idx
        str = argv[0]
        idx = argv[1]

        .local pmc getIndex
        getIndex = get_root_global ['_tcl'], 'getIndex'
        idx = getIndex(idx, str)

        $I0 = length str
        $I0 -= idx

        $I0 = find_not_cclass .CCLASS_WORD, str, idx, $I0
        unless $I0 == idx goto return2
        inc $I0

    return2:
        .return($I0)
    })

    .If(subcommand == 'wordstart', {
        .If(argc !=2, {
            die 'wrong # args: should be "string wordstart string index"'
        })

        .local string str
        .local pmc    idx_p
        str = argv[0]
        idx_p = argv[1]

        .local pmc getIndex
        getIndex = get_root_global ['_tcl'], 'getIndex'
        idx_p = getIndex(idx_p, str)

        .local int pos
        pos = idx_p
        if pos >0 goto check_upper
        pos = 0
        goto pre_loop
    check_upper:
        $I1 = length str
        dec $I1
        if pos <= $I1 goto pre_loop
        pos = $I1
    pre_loop:
        .local int old_idx
        old_idx = pos
    loop2:
        if pos < 0 goto loop_done

        $I1 = is_cclass .CCLASS_WORD, str, pos
        unless $I1 goto loop_done

        dec pos
        goto loop2
    loop_done:
        .If(pos != old_idx, {
            inc pos
        })
    ret_val:
        .return(pos)
    })

    .return ('') # once all commands are implemented, remove this...
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
