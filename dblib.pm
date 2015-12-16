package dblib;
use DB_File;
use Fcntl;

our $tmpdir='/dev/shm/parsearchives';

sub init()
{
    print "writing out data...\n";
    mkdir $tmpdir;
    chmod 0755, $tmpdir or die "could not mkdir/chmod $tmpdir";
}

sub writehash($$)
{
    my ($filename, $hash) = @_;
    $filename="$tmpdir/$filename";
    foreach my $k (sort keys(%$hash)) {
        next unless ref($hash->{$k});
        $hash->{$k}=join("\000", @{$hash->{$k}}); # convert arrayref into string
    }
    unlink $filename;
    my %dbmap;
    tie %dbmap, "DB_File", $filename, O_RDWR|O_CREAT, 0666;
    %dbmap=%$hash;
    untie %dbmap;
}

1;
