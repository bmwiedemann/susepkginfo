package dblib;
use strict;
use DB_File;
use Fcntl;

our $dbdir="db";
# a partial upstream fetch yields a partial parse, which otherwise silently
# replaces a good database; refuse to shrink below this fraction of the
# previous one. Set SUSEPKGINFO_MINKEEP=0 for a deliberate large removal.
our $minkeep=defined $ENV{SUSEPKGINFO_MINKEEP} ? $ENV{SUSEPKGINFO_MINKEEP} : 0.5;

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

sub countkeys($)
{
    my $file=shift;
    my %dbmap;
    tie %dbmap, "DB_File", $file, O_RDONLY or return 0;
    my $n=scalar keys %dbmap;
    untie %dbmap;
    return $n;
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
    my $target="$dbdir/$filename";
    my $was=countkeys($target);
    my $now=scalar keys %flat;
    die "refusing to shrink $filename from $was to $now keys\n"
        if $minkeep>0 and $now < $was*$minkeep;
    # build beside the target so that publishing is an atomic rename
    my $tmp="$target.$$.new";
    unlink $tmp;
    my %dbmap;
    tie %dbmap, "DB_File", $tmp, O_RDWR|O_CREAT|O_EXCL, 0644
        or die "could not create $tmp: $!";
    %dbmap=%flat;
    untie %dbmap;
    rename($tmp, $target) or die "could not rename $tmp: $!";
    printf "%s: %d keys\n", $filename, $now;
}

1;
