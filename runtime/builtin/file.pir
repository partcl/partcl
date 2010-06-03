.HLL 'tcl'
.namespace []

.sub 'file_options' :anon :immediate
    .local pmc opts
    opts = split ' ', 'atime attributes channels copy delete dirname executable exists extension isdirectory isfile join link lstat mtime mkdir nativename normalize owned pathtype readable readlink rename rootname separator size split stat system tail type volumes writable'

    .return(opts)
.end


.sub 'file_types' :anon :immediate
    .local pmc filetypes
    filetypes = new 'Hash'
    filetypes[0o060000] = 'blockSpecial'
    filetypes[0o020000] = 'characterSpecial'
    filetypes[0o040000] = 'directory'
    filetypes[0o010000] = 'fifo'
    filetypes[0o100000] = 'file'
    filetypes[0o120000] = 'link'
    filetypes[0o140000] = 'socket'

    .return(filetypes)
.end

.sub '&file'
    .param pmc argv :slurpy
    .argc()

    .const 'Sub' setVar = 'setVar'
    .const 'Sub' options = 'file_options'
    .const 'Sub' select_option = 'select_option'

    .Unless(argc, {
        die 'wrong # args: should be "file option ?arg ...?"'
    })

    .str(subcommand, {shift argv})
    subcommand = select_option(options, subcommand)

    .local pmc subcommand_proc
    subcommand_proc = get_root_global ['_tcl';'helpers';'file'], subcommand
    if_null subcommand_proc, bad_args

    .tailcall subcommand_proc(argv)

bad_args:
  .return ('') # once all commands are implemented, remove this...
.end

.HLL '_tcl'
.namespace [ 'helpers'; 'file' ]

.sub 'normalize' # RT#40721: Stub for testing
  .param pmc argv
  $P0 = argv[0]
  .return ($P0)
.end

.sub 'join'
  .param pmc argv
  .argc()

  if argc == 0 goto bad_args

  .local string dirsep
  $P1 = get_root_global ['_tcl'], 'slash'
  dirsep = $P1

  .local string result
  result = ''
  .local int ii
  ii = 0

name_loop:
  if ii == argc goto name_loop_done

  .local string name,char
  name = argv[ii]

  char = substr name, 0, 1
  if char == dirsep goto absolute
  result .= name
  goto name_loop_next

absolute:
  result = name

name_loop_next:
  inc ii
  if ii == argc goto name_loop_done
  result .= dirsep
  goto name_loop

name_loop_done:
  .return(result)

bad_args:
  die 'wrong # args: should be "file join name ?name ...?"'
.end

.sub 'stat'
  .param pmc argv
  .argc()

  if argc != 2 goto bad_args

  .local string file,varname
  file = shift argv
  varname = shift argv

  $P1 = new 'OS'
  push_eh no_file
    $P2 = $P1.'stat'(file)
  pop_eh

  $P3 = new 'TclArray'
  $P1 = $P2[8]
  $P3['atime'] = $P1
  $P1 = $P2[10]
  $P3['ctime'] = $P1
  $P1 = $P2[0]
  $P3['dev'] = $P1
  $P1 = $P2[5]
  $P3['gid'] = $P1
  $P1 = $P2[1]
  $P3['ino'] = $P1
  $P1 = $P2[2]
  $P3['mode'] = $P1
  $P1 = $P2[9]
  $P3['mtime'] = $P1
  $P1 = $P2[3]
  $P3['nlink'] = $P1
  $P1 = $P2[7]
  $P3['size'] = $P1

  $I1 = $P2[2]
  $I2 = 0o170000   #S_IFMT
  $I3 = $I1 & $I2

  .const 'Sub' $P4 = 'file_types'
  $S1 = $P4[$I3]
  $P3['type'] = $S1


  $P1 = $P2[4]
  $P3['uid'] = $P1

  setVar(varname, $P3)

  .return('')

# RT#40731: should be more discriminating about the error messages .OS generates
no_file:
  .catch()
  $S0  = 'could not read "'
  $S0 .= file
  $S0 .= '": no such file or directory'
  die $S0
bad_args:
  die 'wrong # args: should be "file stat name varName"'
.end

.sub 'isdirectory'
  .param pmc argv
  .argc()

  if argc != 1 goto bad_args

  .local string file
  file = shift argv

  $P1 = new 'OS'
  push_eh no_file
    $P2 = $P1.'stat'(file)
  pop_eh

  $I1 = $P2[2]
  $I3 = $I1 & 0o170000 #S_IFMT

  if $I3 == 0o040000 goto true # directory mask

  .return(0)

true:
  .return(1)

# RT#40732: should be more discriminating about the error messages .OS generates
no_file:
  .catch()
  $S0  = 'could not read "'
  $S0 .= file
  $S0 .= '": no such file or directory'
  die $S0
bad_args:
  die 'wrong # args: should be "file isdirectory name"'

.end

.sub 'isfile'
  .param pmc argv
  .argc()

  if argc != 1 goto bad_args

  .local string file
  file = shift argv

  $P1 = new 'OS'
  push_eh no_file
    $P2 = $P1.'stat'(file)
  pop_eh

  $I1 = $P2[2]
  $I3 = $I1 & 0o170000   #S_IFMT

  if $I3 == 0o100000 goto true # file mask

  .return(0)

true:
  .return(1)

# RT#40733: should be more discriminating about the error messages .OS generates
no_file:
  .catch()
  $S0  = 'could not read "'
  $S0 .= file
  $S0 .= '": no such file or directory'
  die $S0
bad_args:
  die 'wrong # args: should be "file isfile name"'

.end

.sub 'type'
  .param pmc argv
  .argc()

  if argc != 1 goto bad_args

  .local string file
  file = shift argv

  $P1 = new 'OS'
  push_eh no_file
    $P2 = $P1.'stat'(file)
  pop_eh

  $I1 = $P2[2]
  $I2 = 0o170000   #S_IFMT
  $I3 = $I1 & $I2

  .const 'Sub' $P4 = 'file_types'
  $S1 = $P4[$I3]
  .return ($S1)

# RT#40734: should be more discriminating about the error messages .OS generates
no_file:
  .catch()
  $S0  = 'could not read "'
  $S0 .= file
  $S0 .= '": no such file or directory'
  die $S0
bad_args:
  die 'wrong # args: should be "file type name"'
.end

.sub 'size'
  .param pmc argv
  .argc()

  if argc != 1 goto bad_args

  .local string file
  file = shift argv

  $P1 = new 'OS'
  push_eh no_file
    $P2 = $P1.'stat'(file)
  pop_eh
  $I1 = $P2[7]
  .return ($I1)

# RT#40735: should be more discriminating about the error messages .OS generates
no_file:
  .catch()
  $S0  = 'could not read "'
  $S0 .= file
  $S0 .= '": no such file or directory'
  die $S0
bad_args:
  die 'wrong # args: should be "file size name"'
.end

.sub 'atime'
  .param pmc argv
  .argc()

  if argc != 1 goto bad_args

  .local string file
  file = shift argv

  $P1 = new 'OS'
  push_eh no_file
    $P2 = $P1.'stat'(file)
  pop_eh
  $I1 = $P2[8]
  .return ($I1)

# RT#40736: should be more discriminating about the error messages .OS generates
no_file:
  .catch()
  $S0  = 'could not read "'
  $S0 .= file
  $S0 .= '": no such file or directory'
  die $S0
bad_args:
  die 'wrong # args: should be "file atime name ?time?"'
.end

.sub 'mtime'
  .param pmc argv
  .argc()

  if argc != 1 goto bad_args

  .local string file
  file = shift argv

  $P1 = new 'OS'
  push_eh no_file
    $P2 = $P1.'stat'(file)
  pop_eh
  $I1 = $P2[9]
  .return ($I1)

# RT#40737: should be more discriminating about the error messages .OS generates
no_file:
  .catch()
  $S0  = 'could not read "'
  $S0 .= file
  $S0 .= '": no such file or directory'
  die $S0
bad_args:
  die 'wrong # args: should be "file mtime name ?time?"'
.end

# RT#40722: needs windows OS testing
.sub 'dirname'
    .param pmc argv
    .argc()

    if argc != 1 goto bad_args

    .local string filename
    filename = argv[0]

    .local string separator
    $P0 = get_root_global ['_tcl'], 'slash'
    separator = $P0

    $S0 = substr filename, -1, 1
    if $S0 != separator goto continue
    filename = chopn filename, 1

  continue:
    .local pmc array
    array = split separator, filename
    $S0 = pop array
    unless $S0 == '' goto skip
    push array, $S0

  skip:
    $I0 = elements array
    if $I0 == 0 goto empty

    $P1 = new 'ResizableStringArray'
  loop:
    unless array goto done
    $S0 = shift array
    if $S0 == '' goto loop
    push $P1, $S0
    goto loop

  done:
    $S0 = join separator, $P1
    $S1 = concat separator, $S0 # guessing that this won't be needed in win
    .return($S1)

  empty:
    .return('.')

  bad_args:
    die 'wrong # args: should be "file dirname name"'
.end

# RT#40723: Stub (unixy)
.sub 'tail'
  .param pmc argv
  .argc()

  if argc != 1 goto bad_args
  $S0 = argv[0]
  if $S0 == '' goto whole
  $S1 = substr $S0, -1, 1

  # Trailing dirsep is removed.
  if $S1 != "/" goto continue
  $S0 = chopn $S0, 1

continue:
  .local int pos, idx, last_idx
  pos = 0
  idx = -1
  last_idx = -1
get_last_index:
  idx = index $S0, '/', pos
  if idx == -1 goto done

  pos = idx + 1
  last_idx = idx
  goto get_last_index

done:
  if last_idx == -1 goto whole
  inc last_idx
  $S0 = replace $S0, 0, last_idx, ''

whole:
  .return($S0)

bad_args:
  die 'wrong # args: should be "file tail name"'
.end

.sub 'readable'
  .param pmc argv
  .return(1)
.end

.sub 'delete'
    .param pmc argv
    .argc()
   
    .Unless(argc, {
        tcl_error 'wrong # args: should be "file delete ?options? file ?file ...?"'
    })

    $S0 = argv[0]
    .If($S0=='--force', {
        $P1 = shift argv # XXX ignore --force for now.
    }) 
    $S0 = argv[0]
    .If($S0=='--', {
        $P1 = shift argv # XXX ignore -- for now.
    }) 
    .iter(argv)
    .local pmc os
    os = new 'OS'

    .While(iterator, {
        .str(filename, {shift iterator}) 
        os.'rm'(filename)   
    })

    .return('')
.end

.sub 'exists'
    .param pmc argv
    .argc()

    if argc != 1 goto badargs

    .local pmc os
    os = new 'OS'
    $S0 = argv[0]
    push_eh false
      $P0 = os.'stat'($S0)
    pop_eh

    .return(1)

false:
    .catch()
    .return(0)

badargs:
    die 'wrong # args: should be "file exists name"'
.end

# RT#40727: Stub for test parsing
.sub 'copy'
  .param pmc argv
  .return(0)
.end

.sub 'rootname'
    .param pmc argv
    .argc()

    if argc != 1 goto bad_args

    .local string filename
    filename = argv[0]

    $P0 = split '.', filename
    $I0 = elements $P0
    if $I0 == 1 goto done
    $S0 = pop $P0

    .local string separator
    $P1 = get_root_global ['_tcl'], 'slash'
    separator = $P1

    $I0 = index $S0, separator
    if $I0 != -1 goto done

    join $S0, '.', $P0
    .return($S0)

done:
    .return(filename)

  bad_args:
    die 'wrong # args: should be "file rootname name"'
.end

.sub 'extension'
    .param pmc argv
    .argc()

    # check if filename arg exists
    if argc != 1 goto bad_args

    # get our filename
    $S0 = argv[0]

    # test if filename has dots
    $I0 = index $S0, '.'
    if $I0 == -1 goto no_dot

    # calculate file extension
    $P0 = split '.', $S0
    $S1 = pop $P0
    # include dot
    $S1 = '.' . $S1

    .return($S1)

  no_dot:
    .return('')

  bad_args:
    die 'wrong # args: should be "file extension name"'
.end

# XXX: Stub
.sub 'owned'
  .param pmc argv
  .argc()
  if argc != 1 goto bad_args
  .return(0)
bad_args:
  die 'wrong # args: should be "file owned name"'
.end

# XXX: Stub for test parsing
.sub 'writable'
  .param pmc argv
  .return(1)
.end

# XXX: Stub
.sub 'volumes'
  .param pmc argv
  .argc()
  if argc != 0 goto bad_args

  .return('/')

bad_args:
  die 'wrong # args: should be "file volumes"'
.end

# TT #731 - this is is only a stub implementation

.sub 'executable'
    .param pmc argv
    .argc()

    # check if filename arg exists
    if argc != 1 goto bad_args

    .local string filename
    filename = argv[0]

    # XXX not exported from C to PIR
    .local int STAT_PLATFORM_MODE
    STAT_PLATFORM_MODE = -3 
    .local int UID
    UID = 9

    .local int mode
    push_eh bad_file
      mode = stat filename, STAT_PLATFORM_MODE
    pop_eh

    .local int check_mode
    # is this executable by anyone?
    check_mode = band mode, 1
    if check_mode goto true

    # is this executable by the owner?
    check_mode = band mode, 64
    .local int file_uid
    file_uid = stat filename, UID
    .local int my_uid 
    # XXX Now what?

    # is this executable by a group?
    check_mode = band mode, 8

    # XXX am I in that group?

    # If we got this far, it's not executable
  false:
    .return(0)

    # Standard modes
  true:
    .return(1)

  bad_args:
    die 'wrong # args: should be "file executable name"'
  bad_file:
    pop_eh
    .return(0)
.end

.sub 'split'
    .param pmc argv
    .argc()

    # check if filename arg exists
    if argc != 1 goto bad_args

    .local string filename
    filename = argv[0]

    .list(retval)

    # XXX not platform-independent.
    # XXX this $P0 is a parrot type, not a tcl type.
    $P0 = split '/', filename 

    .local string first_char
    first_char =substr filename, 0, 1
    if first_char != '/' goto done

    $P0[0] = '/' # replaces empty string.

  done:
    assign retval, $P0
    .return(retval)

  bad_args:
    die 'wrong # args: should be "file split name"'
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
