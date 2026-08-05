#!/usr/bin/perl -w
# SPDX-License-Identifier: GPL-2.0-only
use strict;
use XML::Simple;
use lib '.';
use dblib;

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
        next unless $develmap{$pkg}->[0] eq "openSUSE:Factory";
        my $target=$develmap{$develmap{$pkg}->[1]};
        if($target) {
                $develmap{$pkg}=$target;
        } else {
                delete $develmap{$pkg};
        }
}

dblib::init();
dblib::writehash("$target", \%develmap);

