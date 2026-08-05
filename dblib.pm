package dblib;
use strict;
use DB_File;
use Fcntl;

our $dbdir='db';

sub init()
{
    print "writing out data...\n";
    -d $dbdir or mkdir $dbdir or die "could not mkdir $dbdir: $!";
}

# input: arrayref
# output: arrayref
sub dedup($)
{
    my $arrayref=shift;
    my %seen;
    return [grep {!$seen{$_}++} @$arrayref];
}

sub writehash($$;$)
{
    my ($filename, $hash, $dedup) = @_;
    my %flat;
    foreach my $k (keys(%$hash)) {
        my $v=$hash->{$k};
        next unless defined $v;
        if(ref($v)) {
            $v=dedup($v) if $dedup;
            $v=join("\000", @$v);
        }
        $flat{$k}=$v;
    }
    # build beside the target so that publishing is an atomic rename
    my $tmp="$dbdir/$filename.$$.new";
    unlink $tmp;
    my %dbmap;
    tie %dbmap, "DB_File", $tmp, O_RDWR|O_CREAT|O_EXCL, 0644
        or die "could not create $tmp: $!";
    %dbmap=%flat;
    untie %dbmap;
    rename($tmp, "$dbdir/$filename") or die "could not rename $tmp: $!";
}

1;
