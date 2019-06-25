#!/usr/bin/perl -w
use strict;
use lib '.';
use dblib;

sub usage()
{
    print "... | $0 alpinelinuxsrc.dbm\n";
    exit 0;
}

my $target=shift;
if(!$target || @ARGV) {usage}

my %data;
my %srcmap;

while(<>) {
    chomp;
    if (m{^([a-zA-Z]):(.*)$}) {
        #print "matched $1 $2\n";
        $data{$1}=$2;
    } elsif ($_ eq "") {
        $srcmap{$data{P}} = $data{V};
        %data=();
    } else {
        die "unexpected input '$_'";
    }
}

dblib::init();
dblib::writehash("$target", \%srcmap);
