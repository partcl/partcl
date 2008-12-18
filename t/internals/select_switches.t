#!../../parrot
# Copyright (C) 2001-2008, The Perl Foundation.
# $Id: select_switches.t 31511 2008-09-30 14:18:56Z coke $

=head1 NAME

languages/tcl/t/internal/select_switches.t

=head1 DESCRIPTION

Excercise select_switches() - this sub handles switch parsing for various
builtins.

=head1 SYNOPSIS

 % prove t/internal/select_switches.t

=cut

.HLL 'Tcl'
.loadlib 'tcl_group'
.namespace []

.sub main :main
    load_bytecode 'library/Test/More.pir'

    # get the testing functions
    .local pmc plan, ok, is

    plan      = find_global ['Test'; 'More'], 'plan'
    ok        = find_global ['Test'; 'More'], 'ok'
    is        = find_global ['Test'; 'More'], 'is'

    load_bytecode 'languages/tcl/runtime/tcllib.pir'

    plan(32)
    .local string message

    # 1
    message = 'does select_switches() exist in _tcl'
    .local pmc select_switches
    select_switches  = get_root_global ['_tcl'], 'select_switches'
    if select_switches goto ok_1
nok_1:
    ok(0,message)
    end # not much point in doing anything else...
ok_1:
    ok(1,message)
done_1:

    # Setup options
    .local pmc options, argv
    options = new 'TclList'
    options[0] = 'baz'
    options[1] = 'bob'
    options[2] = 'joe'

    # 2-5
    argv = new 'TclList'
    argv[0] = '-joe'
    argv[1] = 'what'
    message='exact match, single, leftover args' 
    $P1 = select_switches(options, argv)

    $I1 = $P1['joe']
    $S1 = message . ' (value of switch key)'
    is ($I1, 1, $S1)

    $I1 = elements $P1
    $S1 = message . ' (no other options set)'
    is ($I1, 1, $S1)

    $I1 = elements argv
    $S1 = message . ' (only one argv left)'
    is ($I1, 1, $S1)

    $S0 = argv[0]
    $S1 = message . ' (value of remaining argv)'
    is ($S0, 'what', $S1)

    # 6-8
    argv = new 'TclList'
    argv[0] = '-joe'
    message='exact match, single, no leftover args'
    $P1 = select_switches(options, argv)

    $I1 = $P1['joe']
    $S1 = message . ' (value of switch key)'
    is ($I1, 1, $S1)

    $I1 = elements $P1
    $S1 = message . ' (no other options set)'
    is ($I1, 1, $S1)

    $I1 = elements argv
    $S1 = message . ' (no args left)'
    is ($I1, 0, $S1)

    # 9-13
    argv = new 'TclList'
    argv[0] = '-joe'
    argv[1] = '-baz'
    argv[2] = 'what'
    message='mutliple options, leftover args'
    $P1 = select_switches(options, argv)

    $I1 = $P1['joe']
    $S1 = message . ' (value of -joe key)'
    is ($I1, 1, $S1)

    $I1 = $P1['baz']
    $S1 = message . ' (value of -bar key)'
    is ($I1, 1, $S1)

    $I1 = elements $P1
    $S1 = message . ' (no other options set)'
    is ($I1, 2, $S1)

    $I1 = elements argv
    $S1 = message . ' (only one argv left)'
    is ($I1, 1, $S1)

    $S0 = argv[0]
    $S1 = message . ' (value of remaining argv)'
    is ($S0, 'what', $S1)

    # 14-17
    argv = new 'TclList'
    argv[0] = '-joe'
    argv[1] = '--'
    argv[2] = '-bob'
    message='end switch'
    $P1 = select_switches(options, argv, 1)

    $I1 = $P1['joe']
    $S1 = message . ' (value of -joe key)'
    is ($I1, 1, $S1)

    $I1 = elements $P1
    $S1 = message . ' (no other options set)'
    is ($I1, 1, $S1)

    $I1 = elements argv
    $S1 = message . ' (only one argv left)'
    is ($I1, 1, $S1)

    $S0 = argv[0]
    $S1 = message . ' (value of remaining argv)'
    is ($S0, '-bob', $S1)

    # 18-22
    argv = new 'TclList'
    argv[0] = '-joke'
    argv[1] = 'bag_o_donuts'
    message='invalid option specified, no exception'
    $P1 = select_switches(options, argv)

    $S2 = $P1['joke']
    $S1 = message . ' (value of -joke key)'
    is ($S2, '', $S1)

    $I1 = elements $P1
    $S1 = message . ' (no other options set)'
    is ($I1, 0, $S1)

    $I1 = elements argv
    $S1 = message . ' (two args left)'
    is ($I1, 2, $S1)

    $S0 = argv[0]
    $S1 = message . ' (argv[0])'
    is ($S0, '-joke', $S1)

    $S0 = argv[1]
    $S1 = message . ' (argv[1])'
    is ($S0, 'bag_o_donuts', $S1)

    # 23
    argv = new 'TclList'
    argv[0] = '-joke'
    argv[1] = 'bag_o_donuts'
    message='invalid option specified, w/ exception'

    push_eh eh_23
      $P1 = select_switches(options, argv, 0, 1)
    pop_eh
   
    $S2= ''   
    goto check_23 

eh_23: 
    pop_eh
    get_results '0', $P2
    $S2 = $P2
check_23:
    is($S2, 'bad switch "-joke": must be -baz, -bob, or -joe', message)

    # 24
    argv = new 'TclList'
    argv[0] = '-joke'
    argv[1] = 'bag_o_donuts'
    message='invalid option specified, w/ exception and --'

    push_eh eh_24
      $P1 = select_switches(options, argv, 1, 1)
    pop_eh
   
    $S2= ''   
    goto check_24

eh_24: 
    get_results '0', $P2
    pop_eh
    $S2 = $P2
check_24:
    is($S2, 'bad switch "-joke": must be -baz, -bob, -joe, or --', message)

    # 25
    argv = new 'TclList'
    argv[0] = '-joke'
    argv[1] = 'bag_o_donuts'
    message='invalid option specified, w/ exception, --, and override name'

    push_eh eh_25
      $P1 = select_switches(options, argv, 1, 1, 'frob')
    pop_eh
   
    $S2= ''   
    goto check_25

eh_25: 
    get_results '0', $P2
    pop_eh
    $S2 = $P2
check_25:
    is($S2, 'bad frob "-joke": must be -baz, -bob, -joe, or --', message)

    # 26-29
    options[2] = 'joe:s' # change this to take a value..

    argv = new 'TclList'
    argv[0] = '-joe'
    argv[1] = 'bag_o_donuts'
    argv[2] = 'what'
    message='switch with a value specified'
    $P1 = select_switches(options, argv)

    $S2 = $P1['joe']
    $S1 = message . ' (value of -joe key)'
    is ($S2, 'bag_o_donuts', $S1)

    $I1 = elements $P1
    $S1 = message . ' (no other options set)'
    is ($I1, 1, $S1)

    $I1 = elements argv
    $S1 = message . ' (only one argv left)'
    is ($I1, 1, $S1)

    $S0 = argv[0]
    $S1 = message . ' (value of remaining argv)'
    is ($S0, 'what', $S1)

    # 30
    options = new 'TclList'
    options[0] = 'good0'
    options[1] = 'good1'

    argv = new 'TclList'
    argv[0] = '-fail'
    argv[1] = 'bag_o_donuts'
    message='invalid option specified, with choice of 2, w/ exception'

    push_eh eh_30
      $P1 = select_switches(options, argv, 0, 1)
    pop_eh
   
    $S2= ''   
    goto check_30 

eh_30: 
    get_results '0', $P2
    pop_eh
check_30:
    is($P2, 'bad switch "-fail": must be -good0 or -good1', message)

    # 31 
    options = new 'TclList'
    options[0] = 'good0'
    options[1] = 'good1'

    argv = new 'TclList'
    argv[0] = '-this -isnt -switches -its -a -string'
    argv[1] = 'bag_o_donuts'
    message='multiword valid arg that just looks like options'

    push_eh eh_31
      $P1 = select_switches(options, argv, 0, 1)
    pop_eh

    $P2 = box ''
    goto check_31 

eh_31: 
    get_results '0', $P2
    pop_eh
check_31:
    is($P2, '', message)

    # 32
    options = new 'TclList'
    options[0] = 'good0'
    options[1] = 'good1'

    argv = new 'TclList'
    argv[0] = '-1'
    argv[1] = 'bag_o_donuts'
    message='negative integer is not a switch'

    push_eh eh_32
      $P1 = select_switches(options, argv, 0, 1)
    pop_eh

    $P2 = box ''
    goto check_32 

eh_32: 
    get_results '0', $P2
    pop_eh
check_32:
    is($P2, '', message)


.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
