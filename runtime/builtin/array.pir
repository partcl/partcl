.HLL 'Tcl'
.namespace []

#
# similar to but not exactly like [string]'s subcommand dispatch
#   - we pass in a boolean (array or not), the array itself, and the name
#   - we know we need an array name for *all* args, so we test for it here.

.sub '&array'
  .param pmc argv :slurpy

  .local int argc
  argc = elements argv

  if argc < 2 goto few_args  # subcommand *and* array name

  .local string subcommand_name
  subcommand_name = shift argv

  .local pmc options
  options = get_root_global ['_tcl'; 'helpers'; 'array'], 'options'

  .local pmc select_option
  select_option  = get_root_global ['_tcl'], 'select_option'

  .local string canonical_subcommand
  canonical_subcommand = select_option(options, subcommand_name)

  .local pmc subcommand_proc
  null subcommand_proc

  subcommand_proc = get_root_global ['_tcl'; 'helpers'; 'array'], canonical_subcommand
  if null subcommand_proc goto bad_args

  .local int is_array
  .local string array_name
  .local pmc the_array

  array_name = shift argv

  null the_array

  .local pmc findVar
  findVar = get_root_global ['_tcl'], 'findVar'
  the_array  = findVar(array_name)

  if_null the_array, array_no

  $I99 = does the_array, 'associative_array'
  unless $I99 goto array_no

  is_array = 1
  goto scommand

array_no:
  is_array = 0

scommand:
  .tailcall subcommand_proc(is_array,the_array,array_name,argv)

bad_args:
  .return ('') # once all commands are implemented, remove this...

few_args:
  die 'wrong # args: should be "array option arrayName ?arg ...?"'

.end

.HLL '_Tcl'

.namespace [ 'helpers' ; 'array' ]

.sub 'exists'
  .param int is_array
  .param pmc the_array
  .param string array_name
  .param pmc argv

  .local int argc
  argc = elements argv
  if argc goto bad_args

  .return (is_array)

bad_args:
  die 'wrong # args: should be "array exists arrayName"'
.end

.sub 'size'
  .param int is_array
  .param pmc the_array
  .param string array_name
  .param pmc argv

  .local int argc
  argc = elements argv
  if argc goto bad_args

  if is_array == 0 goto size_none
  $I0 = the_array
  .return ($I0)

size_none:
  .return (0)

bad_args:
  die 'wrong # args: should be "array size arrayName"'
.end

.sub 'set'
  .param int is_array
  .param pmc the_array
  .param string array_name
  .param pmc argv

  .local int argc
  argc = elements argv
  if argc != 1 goto bad_args

  .local pmc elems
  elems = argv[0]

  .local pmc toList
  toList = get_root_global ['_tcl'], 'toList'
  elems  = toList(elems)

pre_loop:
  .local int count
  count = elems
  $I0 = count % 2
  if $I0 == 1 goto odd_args

  # pull out all the key/value pairs and set them.
  .local int loop
  loop = 0
  .local string key
  .local pmc    val

  .local pmc set
  set = get_root_global ['_tcl'], 'setVar'

  if_null the_array, new_array # create a new array if no var
  goto set_loop

new_array:
  the_array = new 'TclArray'
  set(array_name,the_array) # create an empty named array...

set_loop:
  if loop >= count goto done
  key = elems[loop]
  inc loop
  val = elems[loop]
  inc loop

  # Do this just as if were were calling each set manually, as tcl's
  # error messages indicate it seems to.

  # equals creates an alias, so use assign.
  .local string subvar
  subvar = '' # why is this necessary, if we're doing an assign ???
  assign subvar, array_name
  subvar .= '('
  subvar .= key
  subvar .= ')'
  set(subvar, val)

  goto set_loop

done:
  .return ('')

bad_args:
  die 'wrong # args: should be "array set arrayName list"'

odd_args:
  die 'list must have an even number of elements'
.end


.sub 'get'
  .param int is_array
  .param pmc the_array
  .param string array_name
  .param pmc argv

  .local int argc
  argc = elements argv
  if argc > 1 goto bad_args

  .local string match_str
  # ?pattern? defaults to matching everything.
  match_str = '*'

  # if it's there, get it from the arglist
  if argc == 0 goto no_args
  match_str = shift argv

no_args:
  if is_array == 0 goto not_array

  .local pmc retval

  .local pmc iterator, val
  .local string str

  .local pmc globber
  globber = compreg 'Tcl::Glob'
  .local pmc rule
  rule = globber.'compile'(match_str)

  iterator = iter the_array

  retval = new 'TclList'

  .local int count
  count = 0

push_loop:
  unless iterator goto push_end
  str = shift iterator

  # check for match
  $P2 = rule(str)
  unless $P2 goto push_loop

  inc count
  push retval, str
  val = the_array[str]
  val = clone val
  push retval, val

  branch push_loop

push_end:
  .return(retval)

bad_args:
  die 'wrong # args: should be "array get arrayName ?pattern?"'

not_array:
  .return ('')
.end

.sub 'unset'
  .param int is_array
  .param pmc the_array
  .param string array_name
  .param pmc argv

  .local int argc
  argc = elements argv
  if argc > 1 goto bad_args


  .local string match_str
  # ?pattern? defaults to matching everything.
  match_str = '*'

  # if it's there, get it from the arglist
  if argc == 0 goto no_args
  match_str = shift argv

no_args:
  if is_array == 0 goto not_array

  .local pmc retval

  .local pmc iterator, val
  .local string str

  .local pmc globber
  globber = compreg 'Tcl::Glob'
  .local pmc rule
  (rule, $P0, $P1) = globber.'compile'(match_str)

  iterator = iter the_array

push_loop:
  unless iterator goto push_end
  str = shift iterator

 # check for match
  $P2 = rule(str)
  unless $P2 goto push_loop

  delete the_array[str]

  branch push_loop
push_end:
  .return ('')


bad_args:
   die 'wrong # args: should be "array unset arrayName ?pattern?"'

not_array:
   .return ('')
.end

.sub 'names'
  .param int is_array
  .param pmc the_array
  .param string array_name
  .param pmc argv

  .local pmc retval

  .local int argc
  argc = elements argv
  if argc > 2 goto bad_args

  .local string mode, pattern
  mode = '-glob'
  pattern = '*'
  if argc == 0 goto skip_args
  if argc == 1 goto skip_mode

  mode = shift argv
skip_mode:
  pattern = shift argv
skip_args:

  .local pmc match_proc
  null match_proc

  match_proc = get_hll_global [ 'helpers'; 'array'; 'names_helper' ], mode
  if null match_proc goto bad_mode

  if is_array == 0 goto not_array

  .tailcall match_proc(the_array, pattern)

bad_args:
  die 'wrong # args: should be "array names arrayName ?mode? ?pattern?"'

bad_mode:
  $S0 = 'bad option "'
  $S0 .= mode
  $S0 .= '": must be -exact, -glob, or -regexp'
  die $S0

not_array:
  die '' # is this right? -Coke
.end

.namespace [ 'helpers' ; 'array'; 'names_helper' ]

.sub '-glob'
  .param pmc the_array
  .param string pattern

  .local pmc iterator
  .local string name

  .local pmc globber, retval
  globber = compreg 'Tcl::Glob'
  .local pmc rule
  rule = globber.'compile'(pattern)

  iterator = iter the_array

  retval = new 'TclList'

  .local int count
  count = 0

check_loop:
  unless iterator goto check_end
  name = shift iterator
  $P0 = rule(name)
  unless $P0 goto check_loop

  inc count
  push retval, name

  branch check_loop
check_end:

  .return (retval)
.end

.sub '-exact'
  .param pmc the_array
  .param string match

  .local pmc iterator, retval
  .local string name

  iterator = iter the_array

check_loop:
  unless iterator goto check_end
  name = shift iterator

  if name == match goto found_match
  branch check_loop
check_end:
  .return ('')

found_match:
  .return (name)
.end

.sub '-regexp'
  .param pmc the_array
  .param string pattern

  .local pmc iterator
  .local string name

  .local pmc tclARE, retval
  tclARE = compreg 'PGE::P5Regex'
  .local pmc rule
  rule = tclARE(pattern)

  iterator = iter the_array

  retval = new 'TclList'

  .local int count
  count = 0

check_loop:
  unless iterator goto check_end
  name = shift iterator
  $P0 = rule(name)
  unless $P0 goto check_loop

  inc count
  push retval, name

  branch check_loop
check_end:

  .return (retval)
.end

.sub 'anon' :load :anon
  .local pmc options
  options = new 'TclList'
  options[0] = 'anymore'
  options[1] = 'donesearch'
  options[2] = 'exists'
  options[3] = 'get'
  options[4] = 'names'
  options[5] = 'nextelement'
  options[6] = 'set'
  options[7] = 'size'
  options[8] = 'startsearch'
  options[9] = 'statistics'
  options[10] = 'unset'

  set_root_global ['_tcl'; 'helpers'; 'array'], 'options', options
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
