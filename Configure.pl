#! perl

use strict;
use warnings;
use Getopt::Long;

use Fatal qw(open);

my %options;
GetOptions(\%options, 'parrot-config=s', 'help|?') or usage();
usage() if $options{'help'};

my $config =  $options{'parrot-config'} || "parrot_config";

my %opt;

my @keys = qw(
    bindir
    has_icu
    libdir
    make
    perl
    revision
    slash
    VERSION
    versiondir
);

foreach my $key (@keys) {
      my $value = `$config $key`
          or die "Unable to find parrot_config, $config\n";
      chomp $value;
      $opt{$key} = $value;
}

# Which version of parrot do we need?
open my $cfh, '<', 'config/PARROT_VERSION';
while (<$cfh>) {
    next if /^#/;
    next if /^\s+$/;
    if (/^release:\s*(.*)\s*$/) {
        my $rel = $1;
        # compare dotted notation.
        if (version_int($opt{VERSION}) >= version_int($rel)) {
            print "Need at least r$rel of parrot, using r$opt{VERSION}.\n";
            if ($opt{revision} != 0) {
                print "Warning: this is a development version of parrot (r$opt{revision}).\n";
            }
            last; # that works.
        } else {
            die "We need at least release $rel of parrot but only have $opt{VERSION}.\n";
        }
    } elsif (/^revision:\s*(.*)\s*$/) {
        my $rev = $1;
        if ($opt{revision} == 0) {
            die "This is a released version of parrot ($opt{VERSION}).\nWe need at least r$rev from the svn repository.\n";
        }
        if ($opt{revision} >= $rev) {
            print "Need at least r$rev of parrot, using r$opt{revision}.\n";
            last; # that works.
        } else {
            die "We need at least revision $rev of parrot but only have $opt{revision}.\n"
        }
    }
}

warn <<END_WARN
!! Partcl relies on ICU, which is not linked with this parrot.
   Some features may not work.

END_WARN
  unless $opt{has_icu};

# Get the SVN revision using svn or git-svn
my $cmd = 'svn info';
$cmd    = 'git svn info README' if -d '.git';
my $out = `$cmd`;
$out    =~ /Revision: (\d+)/;
my $partcl_revision = $1;

my $build_tool = $opt{perl} . ' '
               . $opt{libdir}
               . $opt{versiondir}
               . $opt{slash}
               . 'tools'
               . $opt{slash}
               . 'dev'
               . $opt{slash}
               . 'gen_makefile.pl';

my %makefiles = (
    "config/makefiles/root.in" => "Makefile",
    "config/makefiles/pmc.in"  => "src/pmc/Makefile",
    "config/makefiles/ops.in"  => "src/ops/Makefile",
);

foreach my $template (keys %makefiles) {
    my $makefile = $makefiles{$template};
    print "Creating $makefile\n";
    if (system("$build_tool $template $makefile --partcl_revision=$partcl_revision") != 0) {
        die "Unable to create makefile; did you run parrot's 'make install-dev' ?\n";
    }
}


print "Creating Parrot::Installed\n";

open my $fh, '>', 'lib/Parrot/Installed.pm';

print {$fh} "package Parrot::Installed;\n";
print {$fh} "use lib qw($opt{libdir}$opt{versiondir}/tools/lib);\n";
print {$fh} "1;\n";

print "Generating miscellaneous files\n";

my $parrot = "$opt{bindir}/parrot";
add_shebang($parrot, 't/internals/select_switches.t', 'config/misc/select_switches_t.in');
add_shebang($parrot, 't/internals/select_option.t', 'config/misc/select_option_t.in');
replace_parrot($parrot, 'tools/spectcl', 'config/misc/spectcl.in');
chmod 0755, 'tools/spectcl';

print <<"END";

You can now use '$opt{make}' to build partcl.
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

# This is like gen_makefiles, but that adds an inappropriate header.
sub replace_parrot {
    my $exe    = shift;
    my $target = shift;
    my $source = shift;

    my $contents;
    {
        local undef $/;
        open my $fh, '<', $source;
        $contents = <$fh>;
    }
    $contents =~ s/\@parrot\@/$exe/g;

    open my $ofh, '>', $target;
    print {$ofh} $contents;
}

# Convert dotted version to an int.
sub version_int { sprintf('%d%03d%03d', split(/\./, $_[0]))}
