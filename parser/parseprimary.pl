#!/usr/bin/perl -w
# SPDX-License-Identifier: GPL-2.0-only
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

my %srcmap;
my %providesmap=();
my %pkgsrcmap=();
my $version;
my $opensuse = $ENV{OPENSUSE};
my $provides;
my $name;

while(<>) {
    if(m{^\s*<name>([^<>]+)</name>$}) {
        $name = $1
    }
    if(m{<version .*ver="([^"]+)".*/>}) {
        $version = $1;
        $srcmap{$name} = $version if defined $name;
    }
    if($opensuse && m{<rpm:provides>}) {
        $provides = 1;
    }
    if($provides && m{<rpm:entry name="([^"]+)"}) {
        $providesmap{$1} = $name;
    }
    if(m{</rpm:provides>}) {
        $provides = 0;
    }
    if(m{<rpm:sourcerpm>(.+?)-[^-]+-[^-]+.src.rpm</rpm:sourcerpm>}) {
        $srcmap{$1} = $version;
        $pkgsrcmap{$name} = $1;
    }
}

dblib::init();
dblib::writehash("$target", \%srcmap);
if($opensuse) {
    dblib::writehash("provides.dbm", \%providesmap, 1);
    dblib::writehash("pkgsrc.dbm", \%pkgsrcmap);
}
