#!/usr/bin/perl -w
use strict;
use DB_File;
use Fcntl;

sub usage()
{
    print "cat /mounts/dist/full/full-head-x86_64/suse/setup/descr/packages | $0\n";
    exit 0;
}

if(@ARGV) {usage}

my %data;
my %providesmap;

while(<>) {
    chomp;
    if (m/^=(...): (\S+)/) {$data{lc($1)}=$2; $data{section}="";}
    elsif (m/^\+([A-Z][a-z][a-z]):$/) {$data{section}=$1}
    elsif ($data{pkg} && $data{section} eq "Prv") {
        my $name=$_;
        $name =~ s/ = .*//; # strip version
        push(@{$providesmap{$name}},$data{pkg});
    }
}

print "writing out data...\n";
sub writehash($$)
{
    my ($filename, $hash) = @_;
    foreach my $k (sort keys(%$hash)) {
        $hash->{$k}=join(":", @{$hash->{$k}}); # convert arrayref into string
    }
    unlink $filename;
    my %dbmap;
    tie %dbmap, "DB_File", $filename, O_RDWR|O_CREAT, 0666;
    %dbmap=%$hash;
    untie %dbmap;
}

my $tmpdir='/dev/shm/parsearchives';
mkdir $tmpdir;
chmod 0755, $tmpdir or die "could not mkdir/chmod $tmpdir";
writehash("$tmpdir/provides.dbm", \%providesmap);

