#!/usr/bin/perl -w
use strict;
use lib '.';
use dblib;

sub usage()
{
    print "cat info.xml | $0 mageiasrc.dbm\n";
    exit 0;
}

my $target=shift;
if(!$target || @ARGV) {usage}

my %data;
my %srcmap;

while(<>) {
    if (m{<info fn="(.*)-([^-]+)-[^-]+\.\w+\.src"$}) {
        #print "matched $1 $2\n";
        my ($k,$v)=($1,$2);
        $srcmap{$k} = $v;
    }
}

dblib::init();
dblib::writehash("$target", \%srcmap);

