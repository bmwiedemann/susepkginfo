#!/usr/bin/perl -w
use strict;
use lib '.';
use dblib;

sub usage()
{
    print "cat cache/opensuse/filelists.xml | $0 filepkg.dbm\n";
    exit 0;
}

my $target=shift;
if(!$target || @ARGV) {usage}

my %map;
my $pkgname;

while(<>) {
    if(m{<package .*name="([^"]+)".*>}) {
        $pkgname = $1;
    }
    if (m{^  <(file)>([^<]+)</\1>}) {
        #print "matched $1 $2\n";
        $map{$2}=$pkgname;
    }
}

dblib::init();
dblib::writehash("$target", \%map);
