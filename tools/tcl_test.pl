#! perl
# Copyright (C) 2005-2008, The Perl Foundation.
# $Id: tcl_test.pl 31510 2008-09-30 14:17:49Z coke $

use strict;
use warnings;

use vars qw($DIR);
use lib qw(lib);

use Parrot::Installed;
use Parrot::Config;
use Tcl::Version;

use Fatal qw(open);

my $parrot = $PConfig{bindir} . '/parrot';

# the directory to put the tests in
$DIR = 't_tcl';

use File::Spec;

$| = 1;

=head1 NAME

tcl_test.pl

=head1 DESCRIPTION

Run the tests from the Tcl distribution. This script will download
the tests from the Tcl CVS repository and then run them individually
using tcltest. The script also downloads information from the
partcl wiki to see what should be skipped.

=head1 BUGS

We should be able to run the tcl test harness instead of running
each individual C<.test> file.

=head1 SYNOPSIS

  tcl_test.pl

=cut

# Get a listing of skippable files

my $specfile = 'SpecTestStatus.wiki';
warn "Getting a copy of $specfile\n";

my $svn_info = `svn info .`;
$svn_info =~ /Repository Root:\s+(.*)\n/;
my $repo = $1;
my $specstatus = $repo . "/wiki/$specfile";
`svn export $specstatus tools/$specfile`;

# Normally, skip tests marked with @SKIP
# If invoked with --skip, ONLY run those tests, so we can
# figure out what to unskip.

my $skip = 1;
if (@ARGV && $ARGV[0] eq "--skip") {
    $skip = 0;
}

my @skipfiles;
open my $fh, '<', "tools/$specfile";
while (my $line = <$fh>) {
    if ($line =~ m/^\s+\*\s+(\w*)(\s+\@SKIP)?/) {
        my $file = $1;
        my $skippable = defined($2);
        if ($skippable && $skip) {
            push @skipfiles, $file;
        } elsif (!$skippable && !$skip) {
            push @skipfiles, $file;
        }
    }
}

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

    my $command =
        'cvs -z3 -d :pserver:anonymous:\@tcl.cvs.sourceforge.net:'
        . "/cvsroot/tcl co -d $DIR -r $Tcl::Version::CVS tcl/tests";
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
            print "Skipping $file: ";
            if ($skip) {
                print "see $url\n";
            } else {
                print "completes normally.\n";
            }
            next;
        }

        my $cmd = "$parrot tcl.pbc $file 2>&1";
        open my $fh, "$cmd|";

        open my $ofh, '>', "log/${basename}.log";
        while (my $line = <$fh>) {
            tee_msg($ofh, $line);
        }

        close $fh;

        # ...courtesy "perldoc -f system"
        if ($? == -1) {
            tee_msg($ofh, "!! failed to execute: $!\n"); 
        }
        elsif ($? & 127) {
            my $msg = sprintf "!! child died with signal %d, %s coredump\n",
                ($? & 127),  ($? & 128) ? 'with' : 'without';
            tee_msg($ofh, $msg);
        }
        elsif ($?) {
            my $msg = sprintf "!! child exited with value %d\n", $? >> 8;
            tee_msg($ofh, $msg);
        }
        close $ofh;
    }
}

sub tee_msg {
  my $fh = shift;
  print {$fh} join("\n", @_);
  print join("\n", @_);
}

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
