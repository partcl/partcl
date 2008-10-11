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

my $svn_info  = `svn info .`;
$svn_info =~ /Revision:\s+(\d+)/sm;
my $revision = $1;

$svn_info  = `svn info ..`;
$svn_info =~ /Revision:\s+(\d+)/sm;
my $parrot_revision = $1;

open my $fh, "$^X tools/tcl_test.pl|";

my $csv = "docs/spectest-progress.csv";
my $sum = "docs/spectest-current.txt";

open my $csv_fh, '>>', $csv;
open my $sum_fh, '>', $sum;

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

printf {$csv_fh} '"%s",%i,%i,%i,%i,%i,%i,%i' . "\n",
  $time,$revision,$parrot_revision,$files,$total,$passed,$failed,$skipped;

close $sum_fh;
close $csv_fh;
