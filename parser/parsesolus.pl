#!/usr/bin/perl -w
# SPDX-License-Identifier: GPL-2.0-only
use strict;
use lib '.';
use dblib;

sub usage()
{
    print "cat cache/solus/eopkg-index.xml | $0 solussrc.dbm\n";
    exit 0;
}

my $target=shift;
if(!$target || @ARGV) {usage}

my %srcmap;

while(<>) {
    #print "grep "^            <PackageURI" cache/solus/eopkg-index.xml
    if (m{^            <PackageURI>\w/[^/]+/(.*)-([^-]+)-\d+-\d+-x86_64\.eopkg}) {
        #print "matched $1 $2\n";
        my ($k,$v)=($1,$2);
        $srcmap{$k} = $v;
    }
}

dblib::init();
dblib::writehash("$target", \%srcmap);

