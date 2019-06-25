#!/usr/bin/perl -w
use strict;
use lib '.';
use dblib;

sub usage()
{
    print "tar tf cache/archlinux/core.db | $0 archlinuxsrc.dbm\n";
    exit 0;
}

my $target=shift;
if(!$target || @ARGV) {usage}

my %data;
my %srcmap;

while(<>) {
    if (m{^(.*)-([^-]+)-\d+/$}) {
        #print "matched $1 $2\n";
        my ($k,$v)=($1,$2);
        $srcmap{$k} = $v;
    }
}

dblib::init();
dblib::writehash("$target", \%srcmap);

