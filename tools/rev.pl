#! perl

# Get the git revision
my $cmd = 'git rev-parse master';
my $out = `$cmd`;
chomp $out;
print $out;
