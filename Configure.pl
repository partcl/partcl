#! perl

use strict;
use warnings;
use Getopt::Long;

use Fatal qw(open);

my %options;
GetOptions(\%options, 'parrot-config=s', 'help|?') or usage();
usage() if $options{'help'};

my $config =  $options{'parrot-config'} || "parrot_config";

my $perlbin = `$config perl`
        or die "Unable to find parrot_config, $config";
my $libdir = `$config libdir`;
my $bindir = `$config bindir`;
my $versiondir = `$config versiondir`;
my $slash = `$config slash`;
my $make = `$config make`;

chomp($perlbin);
chomp($libdir);
chomp($bindir);
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
    if (system("$build_tool $template $makefile") != 0) {
        die "Unable to create makefile; You may have forgotten to run 'make install-dev'\n";
    } 
}


print "Creating Parrot::Installed\n";

open my $fh, '>', 'lib/Parrot/Installed.pm';

print {$fh} "package Parrot::Installed;\n";
print {$fh} "use lib qw(${libdir}${versiondir}/tools/lib);\n";
print {$fh} "1;\n";

print "Generating miscellaneous files\n";

my $parrot = "$bindir/parrot";
add_shebang($parrot, "t/internals/select_switches.t", "t/internals/select_switches_t.in");
add_shebang($parrot, "t/internals/select_option.t", "t/internals/select_option_t.in");


print <<"END";

You can now use '$make' to build partcl.
END

exit;

sub usage {
    die <<"EOM"
Usage: $0 [--parrot-config=/path/to/parrot_config]
EOM
}

sub add_shebang {
    my $exe    = shift;
    my $target = shift;
    my $source = shift;

    my $shebang = "#!$exe";

    my $contents;
    {
        local undef $/;
        open my $fh, '<', $source;
        $contents = <$fh>;
    }
 
    open my $ofh, '>', $target;
    print {$ofh} $shebang, "\n";
    print {$ofh} $contents;
}
