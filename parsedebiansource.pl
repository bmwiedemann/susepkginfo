#!/usr/bin/perl -w
use strict;
use lib '.';
use dblib;

sub usage()
{
    print "xzcat cache/debian/Source.xz | $0 debiansrc.dbm\n";
    exit 0;
}

my $target=shift;
if(!$target || @ARGV) {usage}

my %data;
my %srcmap;

while(<>) {
    if (m{^(\w+): (.*)}) {
        #print "matched $1 $2\n";
	my ($k,$v)=($1,$2);
        $data{lc($k)}=$v;
	if($k eq "Version") {
            $v=~s/-[^-]+$//; # strip revision
	    $srcmap{$data{package}} = $v;
	}
    }
}

dblib::init();
dblib::writehash("$target", \%srcmap);

