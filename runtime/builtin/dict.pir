.HLL 'tcl'
.namespace []

.sub 'dict_options' :anon :immediate
    .local pmc opts
    opts = split ' ', 'append create exists filter for get incr info keys lappend merge remove replace set size unset update values with'

    .return(opts)
.end

.sub '&dict'
  .param pmc argv :slurpy
  .argc()

  unless argc  goto no_args

  .local pmc retval

  .local string subcommand_name
  subcommand_name = shift argv

    .const 'Sub' options = 'dict_options'

  .local pmc select_option
  select_option  = get_root_global ['_tcl'], 'select_option'

  .local string canonical_subcommand
  canonical_subcommand = select_option(options, subcommand_name, 'subcommand')

  .local pmc subcommand_proc
  null subcommand_proc

  subcommand_proc = get_root_global ['_tcl'; 'helpers'; 'dict'], canonical_subcommand
  if_null subcommand_proc, bad_args
  .tailcall subcommand_proc(argv)

bad_args:
  .return ('') # once all commands are implemented, remove this...

no_args:
  die 'wrong # args: should be "dict subcommand ?argument ...?"'

.end

.HLL '_tcl'

.namespace [ 'helpers'; 'dict' ]

.sub 'append'
  .param pmc argv
  .argc()

  if argc < 2 goto bad_args

  .local pmc read, set
  read = get_root_global ['_tcl'], 'readVar'
  set  = get_root_global ['_tcl'], 'setVar'

  .local pmc dictionary, dict_name
  dict_name = shift argv
  push_eh dict_error
    dictionary = read(dict_name)
  pop_eh
  dictionary = dictionary.'getDictValue'()
  goto got_dict

dict_error:
  .catch()
  $S0 = exception
  $I0 = index $S0, 'variable is array'
  if $I0 != -1 goto cant_dict_array
  dictionary = new 'TclDict'

got_dict:
  .local pmc key, value
  key = shift argv

  # argv now contains all the new elements to append.

  $I0 = exists dictionary[key]
  if $I0 goto vivified
  value = box ''
  goto loop

vivified:
  value = dictionary[key]

loop:
  argc = elements argv
  unless argc goto loop_done
  $S1 = shift argv
  $S2 = value
  $S2 .= $S1
  .local pmc stringy
  stringy = box $S2
  copy value, stringy
  goto loop
loop_done:

  dictionary[key] = value
  set(dict_name, dictionary)
  .return (dictionary)

cant_dict_array:
  $S1 = dict_name
  $S1 = "can't set \"" . $S1
  $S1 .= '": variable is array'
  die $S1

bad_args:
  die 'wrong # args: should be "dict append varName key ?value ...?"'
.end


.sub 'create'
  .param pmc argv

  $I2 = elements argv
  $I3 = $I2 % 2
  if $I3 goto bad_args

  .local pmc retval
  retval = new 'TclDict'

  .local pmc key,value

loop:
  $I1 = elements argv
  unless $I1 goto loop_done
  key = shift argv
  value = shift argv
  retval[key] = value
  goto loop

loop_done:
  .return (retval)

bad_args:
  die 'wrong # args: should be "dict create ?key value ...?"'

.end

.sub 'exists'
  .param pmc argv
  .argc()

  if argc < 2 goto bad_args

  .local pmc dictionary
  dictionary = shift argv
  dictionary = dictionary.'getDictValue'()

  .local pmc key
loop:
  argc = elements argv
  unless argc goto loop_done
  key = shift argv
  dictionary = dictionary[key]
  if_null dictionary, not_exist
  goto loop

loop_done:
  .return (1)

not_exist:
  .return (0)

bad_args:
  die 'wrong # args: should be "dict exists dictionary key ?key ...?"'

.end

.sub 'filter'
  .param pmc argv
  .argc()

  if argc < 2 goto bad_args

  .local pmc dictionary
  dictionary = shift argv
  dictionary = dictionary.'getDictValue'()

  .local pmc options
  options = new 'TclList'
  options[0] = 'key'
  options[1] = 'script'
  options[2] = 'value'

  .local pmc select_option, compileTcl
  select_option  = get_root_global ['_tcl'], 'select_option'
  compileTcl  = get_root_global ['_tcl'], 'compileTcl'
  .local pmc option
  option = shift argv
  option = select_option(options, option, 'filterType')

  .local pmc results, key, value
  results = new 'TclDict'

  if option == 'script' goto do_script_prelude

  .local pmc globber, pattern
  globber = compreg 'Tcl::Glob'
  if argc != 3 goto missing_glob
  pattern = shift argv

  .local pmc rule, match, iterator
  rule = globber.'compile'(pattern)
  iterator = iter dictionary

  if option == 'key' goto do_key_loop

do_value_loop:
  unless iterator goto do_value_done
  key = shift iterator
  value = dictionary[key]
  match = rule(value)
  unless match goto do_value_loop
  results[key] = value
  goto do_value_loop
do_value_done:
  .return (results)

do_key_loop:
  unless iterator goto do_key_done
  key = shift iterator
  match = rule(key)
  unless match goto do_key_loop
  value = dictionary[key]
  results[key] = value
  goto do_key_loop
do_key_done:
  .return (results)

do_script_prelude:
  argc = elements argv
  if argc != 2 goto bad_script_args

  .local pmc vars, body
  vars = shift argv
  vars = vars.'getListValue'()
  $I0 = elements vars
  if $I0 != 2 goto bad_list_size

  body = shift argv
  .local string keyVar,valueVar
  keyVar   = vars[0]
  valueVar = vars[1]

  .local pmc iterator
  iterator = iter dictionary
  .local pmc retval
  retval = new 'TclDict'
  .local pmc body_proc
  body_proc = compileTcl(body)

  .local pmc check_key,check_value
  .local pmc eh
  eh = new 'ExceptionHandler'
  eh.'handle_types'(.CONTROL_CONTINUE,.CONTROL_BREAK)
  set_addr eh, body_handler
script_loop:
  unless iterator goto end_script_loop
  check_key = shift iterator
  setVar(keyVar,check_key)
  check_value = dictionary[check_key]
  setVar(valueVar,check_value)
  push_eh eh
    $P1 = body_proc()
  pop_eh
  $I0 = istrue $P1
  unless $I0 goto script_loop
  retval[check_key] = check_value
  goto script_loop
end_script_loop:
  .return (retval)

body_handler:
  .catch()
  .get_return_code($I0)
  if $I0 == .CONTROL_CONTINUE goto script_loop
  # .CONTROL_BREAK fallthrough
  goto end_script_loop

bad_script_args:
  die 'wrong # args: should be "dict filter dictionary script {keyVar valueVar} filterScript"'

bad_list_size:
  die 'must have exactly two variable names'

missing_glob:
  $S1 = option
  $S1 = 'wrong # args: should be "dict filter dictionary ' . $S1
  $S1 .= ' globPattern"'
  die $S1

bad_args:
  die 'wrong # args: should be "dict filter dictionary filterType ..."'
.end

.sub 'for'
  .param pmc argv
  .argc()

  if argc != 3 goto bad_args

  .local pmc set, script
  set     = get_root_global ['_tcl'], 'setVar'
  script  = get_root_global ['_tcl'], 'compileTcl'

  .local pmc varNames
  .local string keyVar, valueVar

  varNames = shift argv
  varNames = varNames.'getListValue'()
  $I0 = elements varNames
  if $I0 != 2 goto bad_list_size
  keyVar   = varNames[0]
  valueVar = varNames[1]

  .local pmc dictionary
  dictionary = shift argv
  dictionary = dictionary.'getDictValue'()

  .local pmc body,code
  body = shift argv
  code = compileTcl(body)

  .local pmc iterator
  iterator = iter dictionary
for_loop:
  unless iterator goto for_loop_done
  $P1 = shift iterator
  setVar(keyVar,   $P1)
  $S1 = $P1
  $P2 = dictionary[$S1]
  setVar(valueVar, $P2)

  .local pmc eh
  eh = new 'ExceptionHandler'
  eh.'handle_types'(.CONTROL_CONTINUE,.CONTROL_BREAK)
  set_addr eh, loop_handler
  push_eh eh
    code()
  pop_eh

  goto for_loop

loop_handler:
  .catch()
  .get_return_code($I0)
  if $I0 == .CONTROL_CONTINUE goto for_loop
  # .CONTROL_BREAK fallthrough

for_loop_done:

  .return('')

bad_list_size:
  die 'must have exactly two variable names'

bad_args:
  die 'wrong # args: should be "dict for {keyVar valueVar} dictionary script"'

.end

.sub 'get'
  .param pmc argv
  .argc()

  if argc < 1 goto bad_args

  .local pmc dictionary
  dictionary = shift argv
  dictionary = dictionary.'getDictValue'()
  if argc < 0 goto loop_done

  .local pmc key
loop:
  argc = elements argv
  if argc <= 1 goto loop_done
  key = shift argv
  dictionary = dictionary[key]
  if_null dictionary, not_exist
  dictionary = dictionary.'getDictValue'()
  goto loop

loop_done:
  if argc == 0 goto done
  key = shift argv
  dictionary = dictionary[key]
  if_null dictionary, not_exist
done:
  .return (dictionary)

not_exist:
  $S1 = key
  $S1 = 'key "' . $S1
  $S1 .= '" not known in dictionary'
  die $S1

bad_args:
  die 'wrong # args: should be "dict get dictionary ?key key ...?"'
.end

.sub 'incr'
  .param pmc argv
  .argc()

  if argc < 2 goto bad_args
  if argc > 3 goto bad_args

  .local pmc read, set
  read = get_root_global ['_tcl'], 'readVar'
  set  = get_root_global ['_tcl'], 'setVar'

  .local pmc dictionary, dict_name
  dict_name = shift argv
  push_eh dict_error
    dictionary = read(dict_name)
  pop_eh
  dictionary = dictionary.'getDictValue'()
  goto got_dict

dict_error:
  .catch()
  $S0 = exception
  $I0 = index $S0, 'variable is array'
  if $I0 != -1 goto cant_dict_array
  dictionary = new 'TclDict'

got_dict:
  .local pmc key
  key = shift argv

  .local pmc increment
  increment = box 1

  if argc == 2 goto got_increment
  increment = shift argv
  increment = toInteger (increment)

  .local pmc value

got_increment:
  $I0 = exists dictionary[key]
  if $I0 goto vivified
  value = increment
  goto done

vivified:
  value = dictionary[key]
  value = toInteger(value)
  value += increment

done:
  dictionary[key] = value
  set(dict_name, dictionary)
  $P1 = new 'TclList'
  $P1[0] = key
  $P1[1] = value
  .return ($P1)

cant_dict_array:
  $S1 = dict_name
  $S1 = "can't set \"" . $S1
  $S1 .= '": variable is array'
  die $S1

bad_args:
  die 'wrong # args: should be "dict incr varName key ?increment?"'
.end


# This is a stub, doesn't actually generate the info.
# it's exposing the guts of the interface, not sure how if it's appropriate
# to do this in partcl.
.sub 'info'
  .param pmc argv
  .argc()

  if argc != 1 goto bad_args

  .local pmc dictionary
  dictionary = shift argv
  dictionary = dictionary.'getDictValue'()

  .return (dictionary)

bad_args:
  die 'wrong # args: should be "dict info dictionary"'

.end

.sub 'lappend'
  .param pmc argv
  .argc()

  if argc < 2 goto bad_args

  .local pmc read, set
  read = get_root_global ['_tcl'], 'readVar'
  set  = get_root_global ['_tcl'], 'setVar'

  .local pmc dictionary, dict_name
  dict_name = shift argv
  push_eh dict_error
    dictionary = read(dict_name)
  pop_eh
  dictionary = dictionary.'getDictValue'()
  goto got_dict

dict_error:
  .catch()
  $S0 = exception
  $I0 = index $S0, 'variable is array'
  if $I0 != -1 goto cant_dict_array
  dictionary = new 'TclDict'

got_dict:
  .local pmc key, value
  key = shift argv

  # argv now contains all the new list elements to lappend.

  $I0 = exists dictionary[key]
  if $I0 goto vivified
  value = new 'TclList'
  goto loop

vivified:
  value = dictionary[key]
  value = value.'getListValue'()

loop:
  argc = elements argv
  unless argc goto loop_done
  $P1 = shift argv
  push value, $P1
  goto loop
loop_done:

  dictionary[key] = value
  set(dict_name, dictionary)
  .return (dictionary)

cant_dict_array:
  $S1 = dict_name
  $S1 = "can't set \"" . $S1
  $S1 .= '": variable is array'
  die $S1

bad_args:
  die 'wrong # args: should be "dict lappend varName key ?value ...?"'
.end

.sub 'keys'
  .param pmc argv
  .argc()

  if argc < 1 goto bad_args
  if argc > 2 goto bad_args

  .local pmc dictionary
  dictionary = shift argv
  dictionary = dictionary.'getDictValue'()

  .local string pattern
  pattern = '*'
  if argc == 1 goto got_pattern
  pattern = shift argv

got_pattern:
  .local pmc globber
  globber = compreg 'Tcl::Glob'

  .local pmc rule, match
  rule = globber.'compile'(pattern)

  .local pmc iterator
  iterator = iter dictionary

  .local pmc results, key
  results = new 'TclList'
loop:
  unless iterator goto loop_done
  key = shift iterator
  match = rule(key)
  unless match goto loop
  push results, key
  goto loop

loop_done:
  .return (results)

bad_args:
  die 'wrong # args: should be "dict keys dictionary ?pattern?"'
.end


.sub 'merge'
  .param pmc argv
  .argc()

  if argc == 0 goto nothing

  .local pmc retval
  $P1 = argv[0]
  retval = clone $P1
  retval = retval.'getDictValue'()
  if argc == 1 goto done
  $P2 =  shift argv # discard

  .local pmc dictionary,key,value,iterator

dict_loop:
  $I1 = elements argv
  unless $I1 goto done
  dictionary = shift argv
  dictionary = dictionary.'getDictValue'()
  iterator = iter dictionary
key_loop:
  unless iterator goto dict_loop
  key = shift iterator
  value = dictionary[key]
  retval[key] = value
  goto key_loop

done:
  .return (retval)
nothing:
  .return ('')

.end

.sub 'remove'
  .param pmc argv
  .argc()

  if argc < 1  goto bad_args

  .local pmc dictionary
  dictionary = shift argv
  dictionary = dictionary.'getDictValue'()
  dictionary = clone dictionary

  .local pmc key, value
loop:
  argc = elements argv
  unless argc goto loop_done
  key   = shift argv
  delete dictionary[key]
  goto loop

loop_done:
  .return (dictionary)

bad_args:
  die 'wrong # args: should be "dict remove dictionary ?key ...?"'
.end


.sub 'replace'
  .param pmc argv
  .argc()

  if argc < 1  goto bad_args
  if argc == 2 goto bad_args

  .local pmc dictionary
  dictionary = shift argv
  dictionary = dictionary.'getDictValue'()
  dictionary = clone dictionary

  if argc < 0 goto loop_done
  $I0 = mod argc, 2
  if $I0 == 0 goto odd_args # we shifted the dict off, above...

  .local pmc key, value
loop:
  argc = elements argv
  unless argc goto loop_done
  key   = shift argv
  value = shift argv
  dictionary[key] = value
  goto loop

loop_done:
  .return (dictionary)

odd_args:
  die 'missing value to go with key'

bad_args:
  die 'wrong # args: should be "dict replace dictionary ?key value ...?"'
.end

.sub 'set'
  .param pmc argv
  .argc()

  if argc < 3 goto bad_args

  .local pmc read, set
  read = get_root_global ['_tcl'], 'readVar'
  set  = get_root_global ['_tcl'], 'setVar'

  .local pmc dictionary, dict_name
  dict_name = shift argv
  push_eh dict_error
    dictionary = read(dict_name)
  pop_eh
  dictionary = dictionary.'getDictValue'()
  goto got_dict

dict_error:
  .catch()
  $S0 = exception
  $I0 = index $S0, 'variable is array'
  if $I0 != -1 goto cant_dict_array
  dictionary = new 'TclDict'

got_dict:
  .local pmc value
  value = pop argv

  .local pmc key, sub_dict
  sub_dict = dictionary
loop:
  argc = elements argv
  if argc <= 1 goto loop_done
  key = shift argv
  $P1= sub_dict[key]
  # Does this key exist? set it.
  if null $P1 goto new_key
  sub_dict = $P1
  goto loop
new_key:
  $P1 = new 'TclDict'
  sub_dict[key] = $P1
  sub_dict = $P1
  goto loop
loop_done:
  key = shift argv # should be the last one..
  sub_dict[key] = value

  set(dict_name, dictionary)
  .return (dictionary)

cant_dict_array:
  $S1 = dict_name
  $S1 = "can't set \"" . $S1
  $S1 .= '": variable is array'
  die $S1

bad_args:
  die 'wrong # args: should be "dict set varName key ?key ...? value"'
.end

.sub 'size'
  .param pmc argv
  .argc()

  if argc !=1 goto bad_args

  .local pmc dictionary
  dictionary = shift argv
  dictionary = dictionary.'getDictValue'()

  .local int size
  size = elements dictionary
  .return (size)

bad_args:
  die 'wrong # args: should be "dict size dictionary"'

.end

.sub 'unset'
  .param pmc argv
  .argc()

  if argc < 2 goto bad_args

  .local pmc read, set
  read = get_root_global ['_tcl'], 'readVar'
  set  = get_root_global ['_tcl'], 'setVar'

  .local pmc dictionary, dict_name
  dict_name = shift argv
  push_eh dict_error
    dictionary = read(dict_name)
  pop_eh
  dictionary = dictionary.'getDictValue'()
  goto got_dict

dict_error:
  .catch()
  $S0 = exception
  $I0 = index $S0, 'variable is array'
  if $I0 != -1 goto cant_dict_array
  dictionary = new 'TclDict'
  set(dict_name, dictionary)

got_dict:

  .local pmc key, sub_dict
  sub_dict = dictionary
loop:
  argc = elements argv
  if argc <=1 goto loop_done
  key = shift argv
  sub_dict = sub_dict[key]
  if null sub_dict goto not_exist
  goto loop
loop_done:
  key = shift argv # should be the last one..
  delete sub_dict[key]

  .return (dictionary)

not_exist:
  $S1 = key
  $S1 = 'key "' . $S1
  $S1 .= '" not known in dictionary'
  die $S1

cant_dict_array:
  $S1 = dict_name
  $S1 = "can't set \"" . $S1
  $S1 .= '": variable is array'
  die $S1

bad_args:
  die 'wrong # args: should be "dict unset varName key ?key ...?"'
.end

.sub 'update'
  .param pmc argv
  .argc()

  if argc < 4 goto bad_args
  $I0 = argc % 2
  if $I0 goto bad_args

  .local pmc read, set
  read = get_root_global ['_tcl'], 'readVar'
  set  = get_root_global ['_tcl'], 'setVar'

  .local pmc dictionary, dict_name
  dict_name = shift argv
  push_eh dict_error
    dictionary = read(dict_name)
  pop_eh
  dictionary = dictionary.'getDictValue'()
  goto got_dict

dict_error:
  .catch()
  $S0 = exception
  $I0 = index $S0, 'variable is array'
  if $I0 != -1 goto cant_dict_array
  dictionary = new 'TclDict'

got_dict:
  .local pmc body
  body = pop argv

  .local pmc keys,varnames
  keys = new 'TclList'
  varnames = new 'TclList'
  # get lists of both keys & varnames, setting the variables.
key_loop:
  $I0 = elements argv
  unless $I0 goto done_key_loop
  $P1 = shift argv
  push keys, $P1
  $P2 = shift argv
  push varnames, $P2
  $P3 = dictionary[$P1]
  set($P2, $P3)
  goto key_loop
done_key_loop:
# run the body of the script. save the return vaalue.
  .local pmc retval
  $P1 = compileTcl(body)
  retval = $P1()

# go through the varnames, setting the appropriate keys to those values.
  .local pmc iter1,iter2
  iter1 = iter keys
  iter2 = iter varnames
set_loop:
  unless iter1 goto set_loop_done
  $P1 = shift iter1
  $P2 = shift iter2
  $P3 = readVar($P2)
  dictionary[$P1] = $P3
  goto set_loop
set_loop_done:

done:
  .return (retval)

cant_dict_array:
  $S1 = dict_name
  $S1 = "can't set \"" . $S1
  $S1 .= '": variable is array'
  die $S1

bad_args:
  die 'wrong # args: should be "dict update varName key varName ?key varName ...? script"'

.end


.sub 'values'
  .param pmc argv
  .argc()

  if argc < 1 goto bad_args
  if argc > 2 goto bad_args

  .local pmc dictionary
  dictionary = shift argv
  dictionary = dictionary.'getDictValue'()

  .local string pattern
  pattern = '*'
  if argc == 1 goto got_pattern
  pattern = shift argv

got_pattern:
  .local pmc globber
  globber = compreg 'Tcl::Glob'

  .local pmc rule, match
  rule = globber.'compile'(pattern)

  .local pmc iterator
  iterator = iter dictionary

  .local pmc results, key, value
  results = new 'TclList'
loop:
  unless iterator goto loop_done
  key = shift iterator
  value = dictionary[key]
  match = rule(value)
  unless match goto loop
  push results, value
  goto loop

loop_done:
  .return (results)

bad_args:
  die 'wrong # args: should be "dict values dictionary ?pattern?"'
.end

.sub 'with'
  .param pmc argv
  .argc()

  if argc ==0  goto bad_args

  .local pmc read, set
  read = get_root_global ['_tcl'], 'readVar'
  set  = get_root_global ['_tcl'], 'setVar'

  .local pmc dictionary, dict_name
  dict_name = shift argv
  push_eh dict_error
    dictionary = read(dict_name)
  pop_eh
  dictionary = dictionary.'getDictValue'()
  goto got_dict

dict_error:
  .catch()
  $S0 = exception
  $I0 = index $S0, 'variable is array'
  if $I0 != -1 goto cant_dict_array
  dictionary = new 'TclDict'

got_dict:
  .local pmc body
  body = pop argv
  # walk to point in hierarchy for keys..

while_keys:
  .local pmc key
  $I0 = elements argv
  unless $I0 goto done_keys
  key = shift argv
  dictionary=dictionary[key]

done_keys:
  .local pmc iterator
  iterator = iter dictionary

alias_keys:
  unless iterator goto done_alias
  $P1 = shift iterator
  $P2 = dictionary[$P1]
  set($P1,$P2)
  goto alias_keys
done_alias:
  .local pmc retval
  $P1 = compileTcl(body)
  retval = $P1()

  iterator = iter dictionary
update_keys:
  unless iterator goto done_update
  $P1 = shift iterator
  $P2 = readVar($P1)
  dictionary[$P1] = $P2
  goto update_keys

done_update:
  .return (retval)

cant_dict_array:
  $S1 = dict_name
  $S1 = "can't set \"" . $S1
  $S1 .= '": variable is array'
  die $S1

bad_args:
  die 'wrong # args: should be "dict with dictVar ?key ...? script"'
.end
# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
