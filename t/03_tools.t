use strict;
use warnings;
use Test::More;
use Test::Alien;
use Alien::libtiff;
use File::Temp;
use Env qw /@PATH/;
use Path::Tiny qw /path/;

alien_ok 'Alien::libtiff';
#diag(Alien::libtiff->install_type);

if (Alien::libtiff->install_type ('system')) {
    diag "Skipping utility test on system install";
}
elsif (Alien::libtiff->install_type ('share')) {
TODO: {
    local $TODO = 'test needs more debugging';
    
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
    my $have_file = -e path (Alien::libtiff->bin_dir, 'ppm2tiff.exe');
    
    if (!$have_file) {
        diag "Executable file ppm2tiff does not exist, skipping test\n"
    }
    else {
        #system path (Alien::libtiff->bin_dir, 'ppm2tiff'), '-v';
        run_ok( [ 'ppm2tiff', "$pbmfile", "$dest" ] )->success->err;
    }
}
}

done_testing();
