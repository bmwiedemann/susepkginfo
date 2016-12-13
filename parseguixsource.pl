#!/usr/bin/perl -w
use strict;
use dblib;
use JSON::XS;

sub usage()
{
    print "cat guix/packages.json | $0 guixsrc.dbm\n";
    exit 0;
}

my $target=shift;
if(!$target || @ARGV) {usage}

my %data;
my %srcmap;
$/=undef;
my $json=<>;
my $data=decode_json($json);
foreach my $pkg (@$data) {
    my $name=$pkg->{name};
    my $v=$pkg->{version};
    #print $pkg->{"cpe-name"}."/$name has version $v\n";
    $srcmap{$name} = $v;
}

dblib::init();
dblib::writehash("$target", \%srcmap);
