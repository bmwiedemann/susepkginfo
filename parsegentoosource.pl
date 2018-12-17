#!/usr/bin/perl -w
use strict;
use lib '.';
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
    s{.*/}{};
    s{(-r\d+)?\.ebuild\n$}{};
    if (m{^(.*)-([^-]+)$}) {
        #print "matched $1 $2\n";
        my ($k,$v)=($1,$2);
        $srcmap{$k} = $v;
    }
}

dblib::init();
dblib::writehash("$target", \%srcmap);

