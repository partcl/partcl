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

use IO::Handle;

my $svn_info  = `svn info .`;
$svn_info =~ /Revision:\s+(\d+)/sm;
my $revision = $1;

$svn_info  = `svn info ..`;
my $parrot_revision;
if ($svn_info =~ m{https://svn.perl.org/parrot/tags/RELEASE_([0-9_]+)}) {
  $parrot_revision = "v$1";
  $parrot_revision =~ s/_/./g;
} else {
  $svn_info =~ /Revision:\s+(\d+)/sm;
  $parrot_revision = "r$1";
}

my $start = time();

open my $fh, "$^X tools/tcl_test.pl|";

my $csv = "docs/spectest-progress.csv";
my $sum = "docs/spectest-current.txt";
my $results = "spectest_results.log";

open my $csv_fh, '>>', $csv;
open my $sum_fh, '>', $sum;
open my $res_fh, '>', $results;
$sum_fh->autoflush(1);
$res_fh->autoflush(1);

my $epoch = time();
my ($year,$mon,$day,$hour,$min) =(localtime($epoch))[5,4,3,2,1];
$year+=1900;$mon++;
my $time = sprintf "%i-%02i-%02i %02i:%02i", $year,$mon,$day,$hour,$min;

my ($total,$passed,$skipped,$failed,$files) = (0,0,0,0,0);

while (my $line = <$fh>) {
 print $line;
 print {$res_fh} $line;
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
