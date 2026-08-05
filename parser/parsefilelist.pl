#!/usr/bin/perl -w
# SPDX-License-Identifier: GPL-2.0-only
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
open(my $apparmorfd, ">", "db/apparmor-list.txt") or die "could not write db/apparmor-list.txt: $!";

while(<>) {
    if(m{<package .*name="([^"]+)".*>}) {
        $pkgname = $1;
    }
    if (m{^  <(file)>([^<]+)</\1>}) {
        my $file = $2;
        #print "matched $1 $2\n";
        $map{$file} = $pkgname;
        if($file =~ m{^/etc/apparmor|^/usr/share/apparmor|^/etc/apparmor.d}) {
            print $apparmorfd "$file=$pkgname\n";
        }
    }
}

dblib::init();
dblib::writehash("$target", \%map);
