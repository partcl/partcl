#! perl

use strict;
use warnings;

my $perlbin = `parrot_config perl`;
my $libdir = `parrot_config libdir`;
my $versiondir = `parrot_config versiondir`;
my $slash = `parrot_config slash`;
my $make = `parrot_config make`;

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

You can now use '$make' to build Partcl.
END

exit;
