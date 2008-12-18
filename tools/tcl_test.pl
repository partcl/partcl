#! perl
# Copyright (C) 2005-2008, The Perl Foundation.
# $Id: tcl_test.pl 31510 2008-09-30 14:17:49Z coke $

use strict;
use warnings;
use vars qw($DIR);

# the directory to put the tests in
$DIR = 't_tcl';

use File::Spec;

$| = 1;

=head1 NAME

tcl_test.pl

=head1 DESCRIPTION

Run the tests from the Tcl distribution. This script will download
the tests from the Tcl CVS repository and then run them individually
using tcltest.

=head1 BUGS

We should be able to run the tcl test harness instead of running
each individual C<.test> file.

=head1 SYNOPSIS

  tcl_test.pl

=cut

# When testing, avoid these files for now.
my @skipfiles = qw(
  assocd async autoMkindex
  basic binary
  case chanio clock cmdAH cmdMZ cmdInfo config
  dcall dict dstring
  encoding expr env exec execute
  fCmd fileName fileSystem
  history http httpold
  indexObj info init interp io iocmd iogt
  link list lset
  macOSXFCmd macOSXLoad main misc msgcat
  namespace notify
  obj opt
  pid pkg pkgMkIndex platform
  reg regexp regexpComp registry result
  safe socket source stack string stringObj subst
  tcltest thread timer tm trace
  unixFCmd unixFile unixInit unixNotfy unload util
  winConsole winDde winFCmd winFile winNotify winPipe winTime
  ioUtil mathop
);

main();

##
## main()
##
sub main {
    checkout_tests() if not -d $DIR;
    return run_tests();
}

##
## checkout_tests()
##
## Checkout the tests from CVS into $DIR.
##
sub checkout_tests {
    print "Checking out tests from CVS\n";

    my $tag = 'core-8-5-5';    # For the version we're targeting.

    my $command =
        'cvs -z3 -d :pserver:anonymous:\@tcl.cvs.sourceforge.net:'
        . "/cvsroot/tcl co -d $DIR -r $tag tcl/tests";
    my $rc = system $command;

    return ( $rc == 0 );       # just care if it failed, not how
}

##
## run_tests(@globs)
##
## Run the tests...
##

sub run_tests {
    my (@files) = glob File::Spec->catfile( $DIR, '*.test' );
    my $url = 'http://code.google.com/p/partcl/wiki/SpecTestStatus';

    foreach my $file (@files) {
      $file =~ m{/([^.]+).test$};
      my $basename = $1;
      if (grep {$_ eq $basename} @skipfiles) {
        print "Skipping $file: see $url\n";
        next;
      }
      my $cmd = "../../parrot tcl.pbc $file";
      print "$cmd\n";
      system $cmd;
    }
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
