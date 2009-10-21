#! perl

# Get the git revision
my $cmd = 'git rev-parse --short master';
my $out = `$cmd`;
chomp $out;
print $out;
