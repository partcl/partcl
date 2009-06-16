#! perl

use strict;
use warnings;

use vars qw($DIR);
use lib qw(lib);

use Parrot::Installed;
use Parrot::Config;
use Tcl::Version;

use Fatal qw(open);

my $parrot = $PConfig{bindir} . '/parrot';

# the directory to put the tests in
my $target = shift;
my $repo   = ':pserver:anonymous:@tcl.cvs.sourceforge.net/cvsroot/tcl';


`cvs -z3 -d $repo co -d $target  -r $Tcl::Version::CVS tcl`;
