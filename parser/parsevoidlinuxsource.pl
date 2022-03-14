#!/usr/bin/perl -w
# SPDX-License-Identifier: GPL-2.0-only
use strict;
use lib '.';
use dblib;

sub usage()
{
    print "list | $0 voidlinuxsrc.dbm\n";
    exit 0;
}

my $target=shift;
if(!$target || @ARGV) {usage}

my %data;
my %srcmap;
my %varmap;

while(<>) {
    if (m{/([^/]+)/template:version=(.*)$}) {
        my ($k,$v)=($1,$2);
        $v=~s/\$\{(\w+)\}/$varmap{$1}/ge;
        #print "matched $k $v\n";
        $v=~s/^"(.*)"$/$1/;
        $srcmap{$k} = $v;
        next;
    }
    if (m/template-(\w+)=(.*)/) {
        $varmap{$1}=$2;
        #print "added var $1 $2\n";
    }
}

dblib::init();
dblib::writehash("$target", \%srcmap);

