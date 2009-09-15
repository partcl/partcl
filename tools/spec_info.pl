#! perl

=for comment

Track our progress against the test suite.

Run the equivalent of 'make spectest' and update docs/* with the findings
of the current run.

Requires tcl.pbc, and should be run against an up to date partcl checkout with
no local modifications.

=cut

use strict;
use warnings;

use lib qw(lib);

use Parrot::Installed;
use Parrot::Config;

use IO::Handle;

my $revision = `$^X tools/rev.pl`;
my $parrot_revision = 'r' . $PConfig{revision};

my $start = time();

open my $fh, "$^X tools/tcl_test.pl 2>&1|";

my $csv = "docs/spectest-progress.csv";
my $sum = "docs/spectest-current.txt";

open my $csv_fh, '>>', $csv;
open my $sum_fh, '>', $sum;
$sum_fh->autoflush(1);

my $epoch = time();
my ($year,$mon,$day,$hour,$min) =(localtime($epoch))[5,4,3,2,1];
$year+=1900;$mon++;
my $time = sprintf "%i-%02i-%02i %02i:%02i", $year,$mon,$day,$hour,$min;

my ($total,$passed,$skipped,$failed,$files) = (0,0,0,0,0);

while (my $line = <$fh>) {
 print $line;
 if ($line =~ /:\tTotal\t(\d+)\tPassed\t(\d+)\tSkipped\t(\d+)\tFailed\t(\d+)/smg) {
  print {$sum_fh} $line;
  $files++;
  $total+=  $1;
  $passed+= $2;
  $skipped+=$3;
  $failed+= $4;
 }
}

my $end = time();

my $diff = $end - $start;

printf {$csv_fh} '"%s",%i,"%s",%i,%i,%i,%i,%i,%i' . "\n",
  $time,$revision,$parrot_revision,$files,$total,$passed,$failed,$skipped,$diff;

close $sum_fh;
close $csv_fh;
