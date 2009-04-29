#! perl

use strict;
use warnings;
use Getopt::Long;

my %options;
GetOptions(\%options, 'parrot-config=s', 'help|?') or usage();
usage() if $options{'help'};

my $config =  $options{'parrot-config'} || "parrot_config";

my $perlbin = `$config perl`
        or die "Unable to find parrot_config, $config";
my $libdir = `$config libdir`;
my $versiondir = `$config versiondir`;
my $slash = `$config slash`;
my $make = `$config make`;

chomp($perlbin);
chomp($libdir);
chomp($versiondir);
chomp($slash);
chomp($make);

my $build_tool = $perlbin . " "
               . $libdir
               . $versiondir
               . $slash
               . "tools"
               . $slash
               . "dev"
               . $slash
               . "gen_makefile.pl";

my %makefiles = (
    "config/makefiles/root.in" => "Makefile",
    "config/makefiles/pmc.in" => "src/pmc/Makefile",
    "config/makefiles/ops.in" => "src/ops/Makefile",
);

foreach my $template (keys %makefiles) {
    my $makefile = $makefiles{$template};
    print "Creating $makefile\n";
    system("$build_tool $template $makefile");
}

print <<"END";

You can now use '$make' to build partcl.
END

exit;

sub usage {
    die <<"EOM"
Usage: $0 [--parrot-config=/path/to/parrot_config]
EOM
}
