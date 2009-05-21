# Copyright (C) 2009, The Perl Foundation.
# $Id: Tcl.pm 29434 2008-07-14 15:42:24Z coke $

package Parrot::Test::Tcl;

use strict;
use warnings;
our $VERSION = '1.0';

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(tcl_output_is pir_output_is);

use File::Temp qw(tempfile);
use Test::More;
use Parrot::Installed;
use Parrot::Config;

sub tcl_output_is {
    _output_is( 'tcl', 'tcl.pbc', @_);
}

sub pir_output_is {
    _output_is( 'pir', '', @_);
}

sub _output_is {
    my $type        = shift;
    my $parrot_args = shift;
    my $code        = shift;
    my $expected    = shift;
    my $description = shift;
    my %options     = @_;

    # Generate a temp file for the code.
    my ($code_fh,$code_tempfile) = tempfile(
        SUFFIX => ".$type",
        UNLINK => 1
    );
    print {$code_fh} $code;
    close $code_fh;

    # Generate a temp file for the code.
    my (undef, $out_tempfile) = tempfile(
        SUFFIX => '.out',
        UNLINK => 1
    );
    close $code_fh;

    my $cmd = $PConfig{bindir} ."/parrot $parrot_args $code_tempfile > $out_tempfile";

    TODO: {

        local $TODO = $options{todo} if exists $options{todo};

        if (system($cmd) != 0) {
            fail("$description\n$cmd");
            return;
        } 

        my $actual;
        {
            local undef $/;
            open my $out_fh, '<', $out_tempfile;
            $actual = <$out_fh>;
        }
    
        is ($actual, $expected, $description);

    }

    return;
}

1;

__END__

=head1 Parrot::Test::Tcl

Test tcl code from perl.

Until we can self-host all of testing, we have a need for some of our 
egression tests to run in perl.

=head1 BUGS

We used to rely on parrot's testing infrastructure and may again.

=cut

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
