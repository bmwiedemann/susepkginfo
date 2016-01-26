#!/usr/bin/perl -w
use strict;
use dblib;

sub usage()
{
    print "cat /mounts/dist/full/full-head-x86_64/suse/setup/descr/packages | $0\n";
    exit 0;
}

if(@ARGV) {usage}

my %data;
my %providesmap;
my %srcmap;

while(<>) {
    chomp;
    if (m/^=(...): (\S+)/) {
        $data{lc($1)}=$2;
        $data{section}="";
        if($1 eq "Src") {
            my @a=split(" ", $');
            $srcmap{$data{src}} = $a[0];
        }
    }
    elsif (m/^\+([A-Z][a-z][a-z]):$/) {$data{section}=$1}
    elsif (m/^-$data{section}:$/) {$data{section}=""}
    elsif ($data{pkg} && $data{section} eq "Prv") {
        my $name=$_;
        $name =~ s/ = .*//; # strip version
        push(@{$providesmap{$name}},$data{pkg});
    }
}

dblib::init();
dblib::writehash("provides.dbm", \%providesmap, 1);
dblib::writehash("opensusesrc.dbm", \%srcmap);
