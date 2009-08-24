.HLL 'tcl'
.namespace []

.sub 'encoding_options' :anon :immediate
    .local pmc opts
    opts = split ' ', 'convertfrom convertto dirs names system'

    .return(opts)
.end


.sub '&encoding'
  .param pmc argv :slurpy
  .argc()
  .local pmc retval

  unless argc goto no_args

  .local string subcommand_name
  subcommand_name = shift argv

    .const 'Sub' options = 'encoding_options'

  .local pmc select_option
  select_option  = get_root_global ['_tcl'], 'select_option'

  .local string canonical_subcommand
  canonical_subcommand = select_option(options, subcommand_name)

  .local pmc subcommand_proc
  null subcommand_proc

  subcommand_proc = get_root_global ['_tcl'; 'helpers'; 'encoding'], canonical_subcommand
  if_null subcommand_proc, bad_args
  .tailcall subcommand_proc(argv)

bad_args:
  .return ('') # once all commands are implemented, remove this...

no_args:
  die 'wrong # args: should be "encoding option ?arg ...?"'

.end

.HLL '_tcl'

.namespace [ 'helpers'; 'encoding' ]

.sub 'convertfrom'
  .param pmc argv
  .argc()

  if argc == 0 goto bad_args
  if argc > 2  goto bad_args

  .return('')

bad_args:
  die 'wrong # args: should be "encoding convertfrom ?encoding? data"'
.end

.sub 'convertto'
  .param pmc argv
  .argc()

  if argc == 0 goto bad_args
  if argc > 2  goto bad_args

  .return('')

bad_args:
  die 'wrong # args: should be "encoding convertto ?encoding? data"'
.end

.sub 'dirs'
  .param pmc argv
  .argc()

  if argc > 1  goto bad_args

  .return('')

bad_args:
  die 'wrong # args: should be "encoding dirs ?directoryList?"'
.end

.sub 'names'
  .param pmc argv
  .argc()

  if argc != 0 goto bad_args

  .return('')

bad_args:
  die 'wrong # args: should be "encoding names"'
.end

.sub 'system'
  .param pmc argv
  .argc()

  if argc > 1  goto bad_args

  .return('')

bad_args:
  die 'wrong # args: should be "encoding system ?encoding?"'
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
