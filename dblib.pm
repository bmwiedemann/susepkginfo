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

# input: arrayref
# output: array
sub dedup($)
{
        my $arrayref=shift;
        my %h;
        my @a=();
        foreach my $e (@$arrayref) {
            next if($h{$e}++);
            push(@a,$e);
        }
        return \@a;
}

sub writehash($$;$)
{
    my ($filename, $hash, $dedup) = @_;
    $filename="$tmpdir/$filename";
    foreach my $k (sort keys(%$hash)) {
        my $list=$hash->{$k};
        next unless ref($list);
        if($dedup) {$list=dedup($list)}
        $hash->{$k}=join("\000", @$list); # convert into string
    }
    unlink $filename;
    my %dbmap;
    tie %dbmap, "DB_File", $filename, O_RDWR|O_CREAT, 0666;
    %dbmap=%$hash;
    untie %dbmap;
    system("mv", $filename, "db/");
}

1;
