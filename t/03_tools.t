use strict;
use warnings;
use Test::More tests => 3;
use Test::Alien;
use Alien::libtiff;
use File::Temp;
use Env qw /@PATH/;

alien_ok 'Alien::libtiff';
diag(Alien::libtiff->install_type);

SKIP: {
    skip "The default system install on Windows doesn't include libtiff tools",
      2 unless Alien::libtiff->install_type eq 'share';

my $pbmfile = File::Temp->new( SUFFIX => '.pbm' );
my $dest    = File::Temp->new( SUFFIX => '.tif' );
my $pbmheader = <<'END';
P4
8 10
END
my $pbmdata = <<'END';
00000000
00000100
00000100
00000100
00000100
00000100
00000100
01000100
00111000
00000000
END

# raw to ensure that newlines aren't munged on Windows.
open my $fh, '>:raw', $pbmfile;
print {$fh} $pbmheader;
print {$fh} pack 'B*', $pbmdata;
close $fh;

unshift @PATH, Alien::libtiff->bin_dir;
run_ok( [ 'ppm2tiff', "$pbmfile", "$dest" ] )->success;

}
