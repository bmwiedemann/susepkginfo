#!/usr/bin/perl -w
use strict;
use dblib;

sub usage()
{
    print "cat cache/fedora/primary.xml | $0\n";
    exit 0;
}

if(@ARGV) {usage}

my %data;
my %srcmap;

while(<>) {
    if (m{^  <(\w+)>([^<]+)</\1>}) {
        #print "matched $1 $2\n";
        $data{lc($1)}=$2;
    }
    if(m{<version .*ver="([^"]+)".*/>}) {
        $srcmap{$data{name}} = $1;
    }
}

dblib::init();
dblib::writehash("fedorasrc.dbm", \%srcmap);

