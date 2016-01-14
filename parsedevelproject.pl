#!/usr/bin/perl -w
use strict;
use dblib;
use XML::Simple;

sub usage()
{
    print "cat xml | $0 develproject.dbm\n";
    exit 0;
}

my $target=shift;
if(!$target || @ARGV) {usage}

my %develmap;
$/=undef;
my $xml=<>;
my $data=XMLin($xml, ForceArray => 1);
$data=$data->{package};

foreach my $pkg (keys(%$data)) {
        my $d=$data->{$pkg}->{devel};
        if(not $d) {
                next;
        }
        $develmap{$pkg}=[$d->[0]->{project}, $d->[0]->{package}];
}
foreach my $pkg (keys %develmap) {
        # resolve links within Factory
        if($develmap{$pkg}->[0] eq "openSUSE:Factory") {
                my $r=$develmap{$pkg}->[1];
                $develmap{$pkg}=$develmap{$r};
        }
}

dblib::init();
dblib::writehash("$target", \%develmap);

