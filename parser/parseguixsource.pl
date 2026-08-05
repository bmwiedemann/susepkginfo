#!/usr/bin/perl -w
# SPDX-License-Identifier: GPL-2.0-only
use strict;
use JSON::XS;
use lib ".";
use dblib;

sub usage()
{
    print "cat guix/packages.json | $0 guixsrc.dbm\n";
    exit 0;
}

my $target=shift;
if(!$target || @ARGV) {usage}

# compare dotted/dashed version strings field by field, numerically where both
# sides are numeric
sub vercmp($$)
{
    my @a=split(/[.\-_]/, $_[0]);
    my @b=split(/[.\-_]/, $_[1]);
    while(@a or @b) {
        my $x=@a ? shift(@a) : "";
        my $y=@b ? shift(@b) : "";
        my $c=($x=~/^\d+$/ and $y=~/^\d+$/) ? $x <=> $y : $x cmp $y;
        return $c if $c;
    }
    return 0;
}

my %srcmap;
$/=undef;
my $json=<>;
my $data=decode_json($json);
foreach my $pkg (@$data) {
    my $name=$pkg->{name};
    my $v=$pkg->{version};
    next unless defined $name and defined $v;
    # guix ships gcc-4.7 .. gcc-16 all under the name "gcc"
    next if exists $srcmap{$name} and vercmp($v, $srcmap{$name}) <= 0;
    $srcmap{$name} = $v;
}

dblib::init();
dblib::writehash("$target", \%srcmap);
