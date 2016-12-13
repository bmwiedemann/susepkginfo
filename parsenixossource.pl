#!/usr/bin/perl -w
use strict;
use dblib;
use JSON::XS;

sub usage()
{
    print "cat nixos/packages.json.gz | gzip -cd | $0 nixossrc.dbm\n";
    exit 0;
}

my $target=shift;
if(!$target || @ARGV) {usage}

my %data;
my %srcmap;
$/=undef;
my $json=<>;
my $data=decode_json($json);
$data=$data->{packages};
foreach my $pkg (keys(%$data)) {
    my $v=$data->{$pkg};
    my $name=$v->{name};
    unless($name=~s/-([^-]+)$//) {
        #warn("skipping $pkg because '$name' cannot be split");
        next;
    }
    $v=$1;
    #print "$pkg has version $name $v\n";
    $srcmap{$pkg} = $v;
}

dblib::init();
dblib::writehash("$target", \%srcmap);
