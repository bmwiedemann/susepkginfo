#!/usr/bin/perl -w
use strict;
use dblib;

sub usage()
{
    print "cat PACKAGES.TXT | $0 slackwaresrc.dbm\n";
    exit 0;
}

my $target=shift;
if(!$target || @ARGV) {usage}

my %data;
my %srcmap;

while(<>) {
    if (m{^PACKAGE NAME:  (.*)-([^-]+)+-\w+-\d+\.txz$}) {
        #print "matched $1 $2\n";
	my ($k,$v)=($1,$2);
	$srcmap{$k} = $v;
    }
}

dblib::init();
dblib::writehash("$target", \%srcmap);

