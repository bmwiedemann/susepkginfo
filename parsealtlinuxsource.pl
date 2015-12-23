#!/usr/bin/perl -w
use strict;
use dblib;

sub usage()
{
    print "list-of-ebuilds | $0 gentoosrc.dbm\n";
    exit 0;
}

my $target=shift;
if(!$target || @ARGV) {usage}

my %data;
my %srcmap;

while(<>) {
    chomp;
    my @a=split("\t");
    my ($k,$v)=($a[0], $a[1]);
    $v=~s/-[^-]+$//; # strip revision
    $v=~s/^\d+://; # strip epoch
    #print "matched $k $v\n";
    $srcmap{$k} = $v;
}

dblib::init();
dblib::writehash("$target", \%srcmap);

