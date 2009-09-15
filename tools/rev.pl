#! perl

# Get the SVN revision using svn or git-svn
my $cmd = 'svn info';
$cmd    = 'git svn info README' if -d '.git';
my $out = `$cmd`;
$out    =~ /Revision: (\d+)/;
print $1;
