#!/usr/bin/perl -w
use strict;
use lib '.';
use dblib;

sub usage()
{
    print "cat cache/fedora/primary.xml | $0 fedorasrc.dbm\n";
    exit 0;
}

my $target=shift;
if(!$target || @ARGV) {usage}

my %data;
my %srcmap;
my $version;

while(<>) {
    if (m{^  <(\w+)>([^<]+)</\1>}) {
        #print "matched $1 $2\n";
        $data{lc($1)}=$2;
    }
    if(m{<version .*ver="([^"]+)".*/>}) {
        $version = $1;
        $srcmap{$data{name}} = $version;
    }
    if(m{<rpm:sourcerpm>(.+?)-[^-]+-[^-]+.src.rpm</rpm:sourcerpm>}) {
        $srcmap{$1} = $version;
    }
}

dblib::init();
dblib::writehash("$target", \%srcmap);

