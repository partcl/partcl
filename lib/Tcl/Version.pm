package Tcl::Version;

use warnings;
use strict;

use lib qw(lib);

use Fatal qw(open);
use Exporter;

use File::Spec;

our $Patchlevel;
our $Version;
our $CVS;

BEGIN: {

  open my $fh, '<', 'config/TCL_VERSION';
  my $contents;
  {
    undef local $/;
    $contents = <$fh>;
  }
  $contents =~ m/patchlevel:\s+(\S+)\n/;
  $Patchlevel = $1;

  $CVS = 'core-' . $Patchlevel;
  $CVS =~ s/\./-/g;

  $contents =~ m/version:\s*(\S+)\n/;

  $Version = $1;
  $Version =~ s/\.\d$//;
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
